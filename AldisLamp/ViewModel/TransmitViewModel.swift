//
//  TransmitViewModel.swift
//  AldisLamp
//
//  Created by 박세진 on 5/1/26.
//


import Foundation
import Observation
import UIKit
import AVFoundation
import AudioToolbox

@Observable
final class TransmitViewModel {

    // MARK: - Settings (AppStorage 값 동기화)
    var wpm: Int = UserDefaults.standard.integer(forKey: "wpm") == 0 ? 15 : UserDefaults.standard.integer(forKey: "wpm") {
        didSet { UserDefaults.standard.set(wpm, forKey: "wpm") }
    }
    var brightness: Float = UserDefaults.standard.float(forKey: "brightness") == 0 ? 1.0 : UserDefaults.standard.float(forKey: "brightness") {
        didSet { UserDefaults.standard.set(brightness, forKey: "brightness") }
    }
    var preventSleep: Bool = UserDefaults.standard.bool(forKey: "preventSleep") {
        didSet {
            UserDefaults.standard.set(preventSleep, forKey: "preventSleep")
            UIApplication.shared.isIdleTimerDisabled = preventSleep
        }
    }
    var hapticFeedback: Bool = UserDefaults.standard.bool(forKey: "hapticFeedback") {
        didSet { UserDefaults.standard.set(hapticFeedback, forKey: "hapticFeedback") }
    }
    var repeatTransmit: Bool = UserDefaults.standard.bool(forKey: "repeatTransmit") {
        didSet { UserDefaults.standard.set(repeatTransmit, forKey: "repeatTransmit") }
    }

    // MARK: - Properties
    var inputText: String = ""
    var isTransmitting: Bool = false
    var errorMessage: String? = nil

    // MARK: - 시각화 큐 (최대 20개)
    private let maxQueueSize = 20
    var symbolQueue: [MorseSymbol] = []
    var translatedText: String = ""

    // MARK: - SIGNAL 관련
    private var pressStartTime: Date? = nil
    private let ditThreshold: TimeInterval = 0.15
    private var gapTimer: Task<Void, Never>? = nil
    private let charGapDelay: TimeInterval = 0.45
    private let wordGapDelay: TimeInterval = 1.05

    // MARK: - Private
    private let flashService = FlashService()
    private var transmitTask: Task<Void, Never>? = nil

    // MARK: - 시각화 문자열
    var morseDisplayString: String {
        MorseEncoder.toDisplayString(symbolQueue)
    }

    // MARK: - 초기화
    init() {
        UIApplication.shared.isIdleTimerDisabled = preventSleep
    }

    // MARK: - 큐에 심볼 추가
    private func enqueue(_ symbols: [MorseSymbol]) {
        symbolQueue.append(contentsOf: symbols)
        if symbolQueue.count > maxQueueSize {
            symbolQueue.removeFirst(symbolQueue.count - maxQueueSize)
        }
        translatedText = MorseDecoder.decode(symbolQueue)
    }

    // MARK: - 클리어
    func clear() {
        gapTimer?.cancel()
        gapTimer = nil
        symbolQueue = []
        translatedText = ""
    }

    // MARK: - 송출 시작
    func startTransmit() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard !isTransmitting else { return }

        let symbols = MorseEncoder.encode(inputText)
        guard !symbols.isEmpty else { return }

        clear()
        enqueue(symbols)
        isTransmitting = true
        errorMessage = nil

        transmitTask = Task { @MainActor in
            repeat {
                do {
                    try await flashService.transmit(
                        symbols: symbols,
                        wpm: wpm,
                        brightness: brightness,
                        soundFeedback: soundFeedback,
                        hapticFeedback: hapticFeedback
                    )
                } catch is CancellationError {
                    break
                } catch {
                    errorMessage = "플래시 오류: \(error.localizedDescription)"
                    break
                }
            } while repeatTransmit && !Task.isCancelled

            isTransmitting = false
        }
    }

    // MARK: - 송출 중단
    func stopTransmit() {
        transmitTask?.cancel()
        transmitTask = nil
        Task { try? await flashService.stop() }
        isTransmitting = false
    }

    // MARK: - 프리셋
    func sendSOS() {
        inputText = "SOS"
        startTransmit()
    }

    func sendPreset(_ text: String) {
        inputText = text
        startTransmit()
    }

    // MARK: - SIGNAL 누르기 시작
    
    func signalBegan() {
        gapTimer?.cancel()
        gapTimer = nil
        pressStartTime = Date()
        if hapticFeedback {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        Task { try? await flashService.torchOn(brightness: brightness) }
    }

    // MARK: - SIGNAL 떼기
    func signalEnded() {
        guard let start = pressStartTime else { return }
        let duration = Date().timeIntervalSince(start)
        pressStartTime = nil

        Task { try? await flashService.torchOff() }

        let symbol: MorseSymbol = duration < ditThreshold ? .dit : .dah
        enqueue([symbol])

        gapTimer = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(charGapDelay * 1_000_000_000))
            guard !Task.isCancelled else { return }
            enqueue([.charGap])

            try? await Task.sleep(nanoseconds: UInt64((wordGapDelay - charGapDelay) * 1_000_000_000))
            guard !Task.isCancelled else { return }
            if let last = symbolQueue.last, case .charGap = last {
                symbolQueue.removeLast()
            }
            enqueue([.wordGap])
        }
        
        if soundFeedback {
            switch symbol {
            case .dit: SoundService.dit()
            case .dah: SoundService.dah(wpm: wpm)
            default: break
            }
        }
    }

    // MARK: - FlashService 직접 접근
    func torchOn() async throws {
        try await flashService.torchOn(brightness: brightness)
    }

    func torchOff() async throws {
        try await flashService.torchOff()
    }
    
    var soundFeedback: Bool = UserDefaults.standard.bool(forKey: "soundFeedback") {
        didSet { UserDefaults.standard.set(soundFeedback, forKey: "soundFeedback") }
    }
}
