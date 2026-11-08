@preconcurrency import AVFoundation
import SwiftUI

/// Turns a stream of light on/off edges into text. Pure logic, no camera.
struct LightDecoder {
    /// Current estimate of one dot length, in seconds. Adapts to the sender.
    private(set) var unit: TimeInterval
    private(set) var symbols = ""
    private(set) var text = ""
    private(set) var isOn = false
    private var lastEdge: TimeInterval?
    private var gapHandled = false

    init(unit: TimeInterval) { self.unit = unit }

    mutating func reset(unit: TimeInterval) {
        self.unit = unit
        symbols = ""; text = ""; isOn = false; lastEdge = nil; gapHandled = false
    }

    mutating func clearText() { text = ""; symbols = "" }

    /// Report a change of the light's state at time `t`.
    mutating func edge(on: Bool, at t: TimeInterval) {
        guard on != isOn else { return }
        if let last = lastEdge {
            let duration = t - last
            if isOn { pulse(duration) } else { gap(duration) }
        }
        isOn = on
        lastEdge = t
        gapHandled = false
    }

    /// Call regularly: a long silence ends the letter or word even with no new edge.
    mutating func tick(now: TimeInterval) {
        guard !isOn, let last = lastEdge, !gapHandled else { return }
        let silence = now - last
        if silence >= unit * 5 {
            commitLetter()
            if !text.isEmpty, !text.hasSuffix(" ") { text += " " }
            gapHandled = true
        } else if silence >= unit * 2 {
            commitLetter()
        }
    }

    private mutating func pulse(_ d: TimeInterval) {
        if d < unit * 2 {
            symbols += "."
            unit = unit * 0.8 + d * 0.2
        } else {
            symbols += "-"
            unit = unit * 0.8 + (d / 3) * 0.2
        }
        unit = min(max(unit, 0.04), 1.0)
    }

    private mutating func gap(_ d: TimeInterval) {
        if d >= unit * 5 {
            commitLetter()
            if !text.isEmpty, !text.hasSuffix(" ") { text += " " }
        } else if d >= unit * 2 {
            commitLetter()
        }
    }

    private mutating func commitLetter() {
        guard !symbols.isEmpty else { return }
        text.append(Morse.character(for: symbols) ?? "?")
        symbols = ""
    }
}

/// Reads the camera, tracks the brightness of the centre of the frame, and feeds the decoder.
@MainActor
final class Receiver: NSObject, ObservableObject {
    enum Status: Equatable {
        case idle, running, unavailable, denied
    }

    @Published private(set) var status: Status = .idle
    @Published private(set) var level: Double = 0
    @Published private(set) var threshold: Double = 0.5
    @Published private(set) var contrast: Double = 0
    @Published private(set) var isLit = false
    /// What the decoder has produced. Published only when it changes, so the UI is not redrawn every frame.
    @Published private(set) var readout = Readout(symbols: "", text: "", unit: 0.15)
    private var decoder: LightDecoder
    private var lastMeterPublish: TimeInterval = 0

    struct Readout: Equatable {
        var symbols: String
        var text: String
        var unit: TimeInterval
    }

    let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "aldis.receiver.frames")
    private var configured = false
    private var device: AVCaptureDevice?
    private var low = 1.0
    private var high = 0.0
    private var litFrames = 0
    private var darkFrames = 0
    private var ticker: Timer?
    private var startedAt: TimeInterval = 0
    private var exposureLocked = false

    /// Minimum brightness swing (0…1) before flashes count as a signal.
    private let minContrast = 0.05

    init(wpm: Double) {
        decoder = LightDecoder(unit: Morse.dotDuration(wpm: wpm))
        super.init()
    }

    var isAvailable: Bool {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil
    }

    func start(wpm: Double) async {
        guard isAvailable else { status = .unavailable; return }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            guard await AVCaptureDevice.requestAccess(for: .video) else { status = .denied; return }
        case .authorized:
            break
        default:
            status = .denied; return
        }
        if !configured {
            do { try configure() } catch { status = .unavailable; return }
        }
        decoder.reset(unit: Morse.dotDuration(wpm: wpm))
        low = 1; high = 0; litFrames = 0; darkFrames = 0; isLit = false
        exposureLocked = false
        startedAt = CACurrentMediaTime()
        unlockExposure()
        status = .running
        let session = self.session
        queue.async { session.startRunning() }
        syncReadout()
        ticker = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.decoder.tick(now: CACurrentMediaTime())
                self.syncReadout()
            }
        }
    }

    private func syncReadout() {
        let next = Readout(symbols: decoder.symbols, text: decoder.text, unit: decoder.unit)
        if next != readout { readout = next }
    }

    func stop() {
        ticker?.invalidate(); ticker = nil
        let session = self.session
        queue.async { if session.isRunning { session.stopRunning() } }
        if status == .running { status = .idle }
        isLit = false
    }

    func clearText() { decoder.clearText(); syncReadout() }

    /// Let the camera re-meter for a moment, then lock exposure again.
    func recalibrate() {
        low = 1; high = 0
        exposureLocked = false
        startedAt = CACurrentMediaTime()
        unlockExposure()
    }

    private func configure() throws {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw CocoaError(.featureUnsupported)
        }
        self.device = device
        let input = try AVCaptureDeviceInput(device: device)
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: queue)

        session.beginConfiguration()
        session.sessionPreset = .vga640x480
        guard session.canAddInput(input), session.canAddOutput(output) else {
            session.commitConfiguration()
            throw CocoaError(.featureUnsupported)
        }
        session.addInput(input)
        session.addOutput(output)
        session.commitConfiguration()

        // Prefer a high frame rate so short dots are not missed.
        if let range = device.activeFormat.videoSupportedFrameRateRanges.max(by: { $0.maxFrameRate < $1.maxFrameRate }) {
            let fps = min(range.maxFrameRate, 60)
            try? device.lockForConfiguration()
            device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: CMTimeScale(fps))
            device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: CMTimeScale(fps))
            device.unlockForConfiguration()
        }
        configured = true
    }

    private func unlockExposure() {
        guard let device, (try? device.lockForConfiguration()) != nil else { return }
        if device.isExposureModeSupported(.continuousAutoExposure) { device.exposureMode = .continuousAutoExposure }
        if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) { device.whiteBalanceMode = .continuousAutoWhiteBalance }
        device.unlockForConfiguration()
    }

    private func lockExposure() {
        guard let device, (try? device.lockForConfiguration()) != nil else { return }
        if device.isExposureModeSupported(.locked) { device.exposureMode = .locked }
        if device.isWhiteBalanceModeSupported(.locked) { device.whiteBalanceMode = .locked }
        if device.isFocusModeSupported(.locked) { device.focusMode = .locked }
        device.unlockForConfiguration()
        exposureLocked = true
    }

    /// Called on the main actor for every analysed frame.
    fileprivate func handle(brightness b: Double, at t: TimeInterval) {
        guard status == .running else { return }

        // After a short metering period, freeze exposure so the flash is not compensated away.
        if !exposureLocked, t - startedAt > 1.5 { lockExposure() }

        // Track the dark floor and bright ceiling; both drift slowly so they follow lighting changes.
        low = b < low ? b : low + (b - low) * 0.01
        high = b > high ? b : high - (high - b) * 0.01
        let range = high - low

        // The meter is cosmetic: refresh it 20 times a second, not once per frame.
        if t - lastMeterPublish >= 0.05 {
            lastMeterPublish = t
            level = b
            contrast = range
            threshold = low + range * 0.5
        }

        guard range >= minContrast else {
            if isLit { isLit = false; decoder.edge(on: false, at: t); syncReadout() }
            return
        }

        // Hysteresis plus a two-frame debounce.
        let onLevel = low + range * 0.6
        let offLevel = low + range * 0.4
        if b > onLevel { litFrames += 1; darkFrames = 0 } else if b < offLevel { darkFrames += 1; litFrames = 0 }

        if !isLit, litFrames >= 2 {
            isLit = true
            decoder.edge(on: true, at: t)
            syncReadout()
        } else if isLit, darkFrames >= 2 {
            isLit = false
            decoder.edge(on: false, at: t)
            syncReadout()
        }
    }
}

extension Receiver: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
        guard let base = CVPixelBufferGetBaseAddress(pixelBuffer) else { return }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let stride = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let ptr = base.assumingMemoryBound(to: UInt8.self)

        // Average luminance of the centre quarter of the frame, sampling every 4th pixel.
        let x0 = width * 3 / 8, x1 = width * 5 / 8
        let y0 = height * 3 / 8, y1 = height * 5 / 8
        var sum = 0.0
        var count = 0
        var y = y0
        while y < y1 {
            let row = ptr + y * stride
            var x = x0
            while x < x1 {
                let p = row + x * 4
                sum += 0.114 * Double(p[0]) + 0.587 * Double(p[1]) + 0.299 * Double(p[2])
                count += 1
                x += 4
            }
            y += 4
        }
        let brightness = count > 0 ? sum / Double(count) / 255 : 0
        let now = CACurrentMediaTime()
        Task { @MainActor in self.handle(brightness: brightness, at: now) }
    }
}

/// Live camera view behind the receiver's reticle.
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    final class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}
}
