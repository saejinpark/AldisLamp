import SwiftUI
import UIKit

/// Drives the lamp: either plays a text message as Morse code, or follows a manual key.
@MainActor
final class Transmitter: ObservableObject {
    @Published var message: String = "SOS"
    @Published var wpm: Double = 8
    @Published private(set) var isOn = false
    @Published private(set) var isTransmitting = false
    @Published private(set) var activeCharIndex: Int? = nil
    @Published private(set) var progress: Double = 0

    /// Manual key: symbols of the letter being keyed, and the text decoded so far.
    @Published private(set) var keyedSymbols: String = ""
    @Published private(set) var decodedText: String = ""
    private var keyDownTime: Date?
    private var gapTask: Task<Void, Never>?

    @Published var useTorch = Torch.isAvailable
    @Published var useHaptics = true
    @Published var loop = false

    private var task: Task<Void, Never>?
    private let haptic = UIImpactFeedbackGenerator(style: .rigid)

    var events: [Morse.Event] { Morse.events(for: message) }

    /// Total length of the current message in seconds at the current speed.
    var messageDuration: TimeInterval {
        Double(events.reduce(0) { $0 + $1.units }) * Morse.dotDuration(wpm: wpm)
    }

    func start() {
        stop()
        let events = self.events
        guard !events.isEmpty else { return }
        isTransmitting = true
        UIApplication.shared.isIdleTimerDisabled = true
        haptic.prepare()

        task = Task { [weak self] in
            guard let self else { return }
            repeat {
                let totalUnits = Double(events.reduce(0) { $0 + $1.units })
                var elapsedUnits = 0.0
                for event in events {
                    if Task.isCancelled { break }
                    let unit = Morse.dotDuration(wpm: wpm)
                    activeCharIndex = event.charIndex
                    setLamp(event.kind == .on)
                    try? await Task.sleep(for: .seconds(unit * Double(event.units)))
                    elapsedUnits += Double(event.units)
                    progress = elapsedUnits / totalUnits
                }
                setLamp(false)
                if !Task.isCancelled && loop {
                    try? await Task.sleep(for: .seconds(Morse.dotDuration(wpm: wpm) * 7))
                }
            } while loop && !Task.isCancelled
            if !Task.isCancelled { finish() }
        }
    }

    /// Stops any transmission and releases the manual key. Safe to call at any time.
    func stop() {
        task?.cancel()
        task = nil
        keyDownTime = nil
        finish()
    }

    private func finish() {
        setLamp(false)
        isTransmitting = false
        activeCharIndex = nil
        progress = 0
        UIApplication.shared.isIdleTimerDisabled = false
    }

    // MARK: Manual key

    func keyDown() {
        guard !isTransmitting, keyDownTime == nil else { return }
        gapTask?.cancel()
        keyDownTime = .now
        setLamp(true)
    }

    func keyUp() {
        guard let down = keyDownTime else { return }
        keyDownTime = nil
        setLamp(false)

        let unit = Morse.dotDuration(wpm: wpm)
        let held = Date.now.timeIntervalSince(down)
        keyedSymbols += held < unit * 2 ? "." : "-"

        // A pause of 3 units ends the letter; 7 units ends the word.
        gapTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(unit * 3))
            guard !Task.isCancelled, let self else { return }
            self.commitKeyedLetter()
            try? await Task.sleep(for: .seconds(unit * 4))
            guard !Task.isCancelled else { return }
            if !self.decodedText.isEmpty, !self.decodedText.hasSuffix(" ") {
                self.decodedText += " "
            }
        }
    }

    private func commitKeyedLetter() {
        guard !keyedSymbols.isEmpty else { return }
        decodedText.append(Morse.character(for: keyedSymbols) ?? "?")
        keyedSymbols = ""
    }

    func clearDecoded() {
        gapTask?.cancel()
        keyedSymbols = ""
        decodedText = ""
    }

    private func setLamp(_ on: Bool) {
        guard on != isOn else { return }
        isOn = on
        if useTorch { Torch.set(on) }
        if useHaptics && on { haptic.impactOccurred(intensity: 0.8) }
    }
}
