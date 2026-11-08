import SwiftUI

struct ContentView: View {
    @StateObject private var tx = Transmitter()
    @StateObject private var rx = Receiver(wpm: 8)
    @State private var mode: Mode = .message
    @State private var showReference = false
    @FocusState private var messageFocused: Bool
    @Environment(\.scenePhase) private var scenePhase

    enum Mode: String, CaseIterable, Identifiable {
        case message = "송신"
        case manual = "수동 키"
        case receive = "수신"
        var id: String { rawValue }
        var title: LocalizedStringKey {
            switch self {
            case .message: "송신"
            case .manual: "수동 키"
            case .receive: "수신"
            }
        }
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let landscape = geo.size.width > geo.size.height
                if landscape {
                    // Wide: the lamp (or camera) fills the left half; the controls scroll on the right.
                    HStack(spacing: 0) {
                        hero
                            .padding(DS.Space.xl)
                            .frame(width: geo.size.width * 0.46)
                            .frame(maxHeight: .infinity)
                        ScrollView {
                            controls
                                .padding(.trailing, DS.Space.xl)
                                .padding(.vertical, DS.Space.md)
                        }
                        .scrollDismissesKeyboard(.interactively)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: DS.Space.xxl) {
                            hero
                                .frame(maxWidth: 300)
                                .padding(.top, DS.Space.sm)
                            controls
                        }
                        .padding(.horizontal, DS.Space.xl)
                        .padding(.bottom, DS.Space.xxxl)
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
            }
            .background(DeckBackground().ignoresSafeArea())
            .navigationTitle("Aldis Lamp")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showReference = true } label: {
                        Label("모스 부호표", systemImage: "tablecells")
                    }
                }
            }
            .sheet(isPresented: $showReference) { ReferenceSheet() }
        }
        .tint(.brassLight)
        .foregroundStyle(Color.ink)
        .onChange(of: scenePhase) { _, phase in
            // Never leave the torch burning or the camera running in the background.
            if phase != .active { tx.stop(); rx.stop() }
        }
        .onChange(of: mode) { old, new in
            if old == .receive { rx.stop() }
            if new == .receive { Task { await rx.start(wpm: tx.wpm) } }
        }
    }

    /// The lamp, or the camera in receive mode.
    @ViewBuilder private var hero: some View {
        if mode == .receive {
            ReceiveView(rx: rx, wpm: $tx.wpm)
        } else {
            LampView(isOn: tx.isOn)
        }
    }

    /// Mode picker, the panel for the current mode, and the transmit settings.
    private var controls: some View {
        VStack(spacing: DS.Space.xxl) {
            Picker("모드", selection: $mode) {
                ForEach(Mode.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            .disabled(tx.isTransmitting)

            switch mode {
            case .message: messagePanel
            case .manual: manualPanel
            case .receive: receivePanel
            }

            if mode != .receive { settingsPanel }
        }
    }

    // MARK: Message mode

    private var messagePanel: some View {
        VStack(alignment: .leading, spacing: DS.Space.lg - 2) {
            TextField("보낼 메시지", text: $tx.message)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .font(.system(.title3, design: .monospaced))
                .padding(DS.Space.md)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: DS.Radius.control))
                .focused($messageFocused)
                .disabled(tx.isTransmitting)
                .onSubmit { tx.start() }

            messagePreview

            GlassEffectContainer(spacing: DS.Space.sm + 2) {
                HStack(spacing: DS.Space.sm + 2) {
                    Button {
                        messageFocused = false
                        tx.isTransmitting ? tx.stop() : tx.start()
                    } label: {
                        Label(tx.isTransmitting ? "정지" : "송신", systemImage: tx.isTransmitting ? "stop.fill" : "paperplane.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DS.Space.sm + 2)
                    }
                    .buttonStyle(.glassProminent)
                    .foregroundStyle(Color.deck)
                    .disabled(tx.events.isEmpty)

                    Toggle(isOn: $tx.loop) {
                        Label("반복", systemImage: "repeat")
                            .padding(.vertical, DS.Space.sm + 2)
                    }
                    .toggleStyle(.button)
                    .buttonStyle(.glass)
                }
            }

            if tx.isTransmitting {
                ProgressView(value: tx.progress)
                    .tint(.beam)
            }

            speedControl(caption: "전체 길이 약 \(tx.messageDuration, specifier: "%.1f")초")
        }
    }

    /// Each character of the message with its Morse code; the one being sent lights up.
    private var messagePreview: some View {
        let chars = Array(tx.message.uppercased())
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: DS.Space.sm + 2) {
                ForEach(Array(chars.enumerated()), id: \.offset) { index, ch in
                    let active = tx.activeCharIndex == index
                    let unknown = ch != " " && Morse.code(for: ch) == nil
                    VStack(spacing: 2) {
                        Text(ch == " " ? "␣" : String(ch))
                            .font(.system(.body, design: .monospaced, weight: .bold))
                        Text(ch == " " ? "/" : (Morse.code(for: ch) ?? "?"))
                            .font(.system(.caption, design: .monospaced))
                    }
                    .padding(.horizontal, DS.Space.xs + 2)
                    .padding(.vertical, DS.Space.xs)
                    .glassEffect(active ? .regular.tint(Color.beam.opacity(0.35)) : .identity, in: RoundedRectangle(cornerRadius: DS.Radius.chip))
                    .foregroundStyle(active ? Color.beam : (unknown ? Color.signalError : Color.ink))
                }
            }
        }
        .frame(minHeight: 44)
    }

    // MARK: Manual mode

    private var manualPanel: some View {
        VStack(spacing: DS.Space.md) {
            Text("버튼을 누르는 동안 셔터가 열립니다. 짧게 누르면 점(·), 길게 누르면 선(−).")
                .font(.subheadline)
                .foregroundStyle(Color.inkMuted)
                .multilineTextAlignment(.center)

            KeyButton(isDown: tx.isOn, onDown: tx.keyDown, onUp: tx.keyUp)
                .frame(height: 120)

            ReadoutView(symbols: tx.keyedSymbols, text: tx.decodedText, onClear: tx.clearDecoded)

            speedControl(title: "기준 속도", caption: "점 길이의 2배보다 짧게 누르면 점, 길면 선으로 읽습니다. 3배 쉬면 글자, 7배 쉬면 띄어쓰기입니다.")
        }
    }

    // MARK: Receive mode

    private var receivePanel: some View {
        VStack(spacing: DS.Space.md) {
            ReadoutView(symbols: rx.readout.symbols, text: rx.readout.text, onClear: rx.clearText)

            GlassEffectContainer(spacing: DS.Space.sm + 2) {
                HStack(spacing: DS.Space.sm + 2) {
                    Button {
                        if rx.status == .running { rx.stop() } else { Task { await rx.start(wpm: tx.wpm) } }
                    } label: {
                        Label(rx.status == .running ? "수신 정지" : "수신 시작", systemImage: rx.status == .running ? "stop.fill" : "dot.radiowaves.left.and.right")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DS.Space.sm + 2)
                    }
                    .buttonStyle(.glassProminent)
                    .foregroundStyle(Color.deck)
                    .disabled(rx.status == .unavailable || rx.status == .denied)

                    Button {
                        rx.recalibrate()
                    } label: {
                        Label("재보정", systemImage: "camera.metering.center.weighted")
                            .padding(.vertical, DS.Space.sm + 2)
                    }
                    .buttonStyle(.glass)
                    .disabled(rx.status != .running)
                }
            }

            speedControl(title: "예상 속도", caption: "상대 램프의 속도를 대략 맞춰 두면 첫 글자부터 잘 읽힙니다. 이후에는 받은 신호에 맞춰 자동으로 보정합니다.")
        }
    }

    // MARK: Shared pieces

    private func speedControl(title: LocalizedStringKey = "속도", caption: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.xs + 2) {
            HStack {
                Text(title)
                Spacer()
                Text("\(Int(tx.wpm)) WPM · 점 \(Int(Morse.dotDuration(wpm: tx.wpm) * 1000)) ms")
                    .monospacedDigit()
                    .foregroundStyle(Color.inkMuted)
            }
            .font(.subheadline)
            Slider(value: $tx.wpm, in: 3...25, step: 1)
            Text(caption)
                .font(.caption)
                .foregroundStyle(Color.inkMuted)
        }
    }

    private var settingsPanel: some View {
        VStack(spacing: 0) {
            Toggle(isOn: $tx.useTorch) {
                Label("후면 손전등 사용", systemImage: "flashlight.on.fill")
            }
            .disabled(!Torch.isAvailable)
            if !Torch.isAvailable {
                Text("이 기기에는 손전등이 없어 화면의 램프만 깜빡입니다.")
                    .font(.caption)
                    .foregroundStyle(Color.inkMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, DS.Space.xs)
            }
            Divider().padding(.vertical, DS.Space.sm + 2)
            Toggle(isOn: $tx.useHaptics) {
                Label("진동", systemImage: "iphone.radiowaves.left.and.right")
            }
        }
        .padding(DS.Space.lg - 2)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: DS.Radius.card))
    }
}

/// Camera view with a centre reticle and a live brightness meter.
struct ReceiveView: View {
    @ObservedObject var rx: Receiver
    @Binding var wpm: Double

    var body: some View {
        VStack(spacing: DS.Space.sm) {
            ZStack {
                Color.clear
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: DS.Radius.card))
                if rx.status == .running || rx.status == .idle, rx.isAvailable {
                    CameraPreview(session: rx.session)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.card))
                } else {
                    VStack(spacing: DS.Space.sm) {
                        Image(systemName: "camera.fill")
                            .font(.largeTitle)
                        Text(rx.status == .denied
                             ? "설정에서 카메라 접근을 허용해 주세요."
                             : "이 기기에는 사용할 수 있는 카메라가 없습니다.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                    }
                    .foregroundStyle(Color.inkMuted)
                    .padding(DS.Space.lg)
                }

                // Reticle over the region being measured.
                if rx.isAvailable, rx.status != .denied {
                    RoundedRectangle(cornerRadius: DS.Radius.chip)
                        .strokeBorder(rx.isLit ? Color.beam : Color.brassLight.opacity(0.7), lineWidth: rx.isLit ? 4 : 2)
                        .frame(width: 80, height: 80)
                        .shadow(color: rx.isLit ? Color.beam.opacity(0.9) : .clear, radius: 12)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: 300)
            .animation(.easeOut(duration: 0.05), value: rx.isLit)

            // Brightness meter with the detection threshold.
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Color.clear.glassEffect(.regular, in: Capsule())
                    Capsule()
                        .fill(rx.isLit ? Color.beam : Color.brass)
                        .frame(width: geo.size.width * rx.level)
                    Rectangle()
                        .fill(Color.ink)
                        .frame(width: 2)
                        .offset(x: geo.size.width * rx.threshold)
                }
            }
            .frame(height: 10)
            .frame(maxWidth: 300)

            Text(statusLine)
                .font(.caption)
                .foregroundStyle(Color.inkMuted)
                .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(rx.isLit ? "빛 감지됨" : "빛 없음")
    }

    private var statusLine: LocalizedStringKey {
        switch rx.status {
        case .running:
            let unitMs = Int(rx.readout.unit * 1000)
            return rx.contrast < 0.05
                ? "상대 램프를 사각형 안에 맞추세요"
                : "밝기 \(rx.level, format: .percent.precision(.fractionLength(0))) · 점 \(unitMs) ms로 읽는 중"
        case .idle: return "수신 시작을 누르면 카메라가 켜집니다"
        case .denied: return "카메라 권한 없음"
        case .unavailable: return "카메라 없음"
        }
    }
}

/// What the manual key or the camera has spelled so far.
struct ReadoutView: View {
    var symbols: String
    var text: String
    var onClear: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.sm) {
            HStack {
                Text("해독")
                    .font(.subheadline)
                    .foregroundStyle(Color.inkMuted)
                Spacer()
                Text(symbols.isEmpty ? " " : symbols)
                    .font(.system(.title3, design: .monospaced, weight: .bold))
                    .foregroundStyle(Color.beam)
                Button("지우기", action: onClear)
                    .font(.subheadline)
                    .disabled(text.isEmpty && symbols.isEmpty)
            }
            Text(text.isEmpty ? "아직 받은 글자가 없습니다." : text)
                .font(.system(.title2, design: .monospaced))
                .foregroundStyle(text.isEmpty ? Color.inkMuted : Color.ink)
                .frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
                .textSelection(.enabled)
        }
        .padding(DS.Space.lg - 2)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: DS.Radius.card))
    }
}

/// A press-and-hold key. Reports press down and release.
struct KeyButton: View {
    var isDown: Bool
    var onDown: () -> Void
    var onUp: () -> Void

    var body: some View {
        Text(isDown ? "송신 중" : "눌러서 신호")
            .font(.title2.weight(.bold))
            .foregroundStyle(Color.deck)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .glassEffect(.regular.tint(isDown ? Color.brassLight : Color.brass).interactive(), in: RoundedRectangle(cornerRadius: DS.Radius.key))
            .scaleEffect(isDown ? 0.97 : 1)
            .shadow(color: Color.beam.opacity(isDown ? 0.35 : 0), radius: 16)
            .contentShape(Rectangle())
            .overlay(PressRecognizer(onDown: onDown, onUp: onUp))
            .accessibilityLabel("신호 키")
            .accessibilityAddTraits(.isButton)
    }
}

/// Morse code reference card.
struct ReferenceSheet: View {
    @Environment(\.dismiss) private var dismiss
    private let columns = [GridItem(.adaptive(minimum: 90), spacing: DS.Space.sm)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: DS.Space.sm) {
                    ForEach(Morse.referenceOrder, id: \.self) { ch in
                        HStack {
                            Text(String(ch)).bold()
                            Spacer()
                            Text(Morse.table[ch] ?? "")
                        }
                        .font(.system(.body, design: .monospaced))
                        .padding(DS.Space.sm + 2)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: DS.Radius.sm))
                    }
                }
                .padding(DS.Space.xl)

                VStack(alignment: .leading, spacing: DS.Space.xs + 2) {
                    Text("타이밍").font(.headline)
                    Text("점 1 · 선 3 · 글자 안 간격 1 · 글자 사이 3 · 단어 사이 7 (점 길이 기준)")
                    Text("SOS = · · · − − − · · ·")
                }
                .font(.subheadline)
                .foregroundStyle(Color.inkMuted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DS.Space.xl)
            }
            .background(DeckBackground().ignoresSafeArea())
            .navigationTitle("모스 부호표")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("닫기") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}

/// The deck: dark, with faint ambient light so Liquid Glass has something to refract.
struct DeckBackground: View {
    var body: some View {
        ZStack {
            Color.deck
            RadialGradient(colors: [Color.brassDark.opacity(0.45), .clear], center: .topLeading, startRadius: 0, endRadius: 520)
            RadialGradient(colors: [Color.seaGlow.opacity(0.6), .clear], center: .bottomTrailing, startRadius: 0, endRadius: 600)
        }
    }
}

/// Fires on touch-down with no delay and on release even if the finger drifts.
/// A UIKit recogniser is used because a SwiftUI drag gesture inside a ScrollView can be
/// cancelled by the scroll view as soon as the finger moves, releasing the key mid-dash.
struct PressRecognizer: UIViewRepresentable {
    var onDown: () -> Void
    var onUp: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onDown: onDown, onUp: onUp) }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let press = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.changed(_:)))
        press.minimumPressDuration = 0
        press.allowableMovement = .greatestFiniteMagnitude
        press.cancelsTouchesInView = false
        press.delegate = context.coordinator
        view.addGestureRecognizer(press)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.onDown = onDown
        context.coordinator.onUp = onUp
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var onDown: () -> Void
        var onUp: () -> Void
        private var isDown = false

        init(onDown: @escaping () -> Void, onUp: @escaping () -> Void) {
            self.onDown = onDown; self.onUp = onUp
        }

        @objc func changed(_ g: UILongPressGestureRecognizer) {
            switch g.state {
            case .began:
                if !isDown { isDown = true; onDown() }
            case .ended, .cancelled, .failed:
                if isDown { isDown = false; onUp() }
            default:
                break
            }
        }

        // Let the scroll view keep working around the key, but never let it steal a press in progress.
        func gestureRecognizer(_ g: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool { true }
        func gestureRecognizer(_ g: UIGestureRecognizer, shouldBeRequiredToFailBy other: UIGestureRecognizer) -> Bool { false }
        func gestureRecognizer(_ g: UIGestureRecognizer, shouldRequireFailureOf other: UIGestureRecognizer) -> Bool { false }
    }
}
