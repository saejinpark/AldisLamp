//
//  FlashService.swift
//  AldisLamp
//
//  Created by 박세진 on 5/1/26.
//

import AVFoundation

actor FlashService {

    // MARK: - Properties
    private let device: AVCaptureDevice? = AVCaptureDevice.default(for: .video)

    // MARK: - 단위 시간 (나노초)
    private func ditDuration(wpm: Int) -> UInt64 {
        UInt64(1_200_000_000 / wpm)
    }

    // MARK: - 플래시 제어
    func torchOn(brightness: Float = 1.0) throws {
        guard let device, device.hasTorch, device.isTorchAvailable else { return }
        try device.lockForConfiguration()
        try device.setTorchModeOn(level: brightness)
        device.unlockForConfiguration()
    }

    func torchOff() throws {
        guard let device, device.hasTorch else { return }
        try device.lockForConfiguration()
        device.torchMode = .off
        device.unlockForConfiguration()
    }

    // MARK: - 송출
    func transmit(symbols: [MorseSymbol], wpm: Int, brightness: Float) async throws {
        let dit = ditDuration(wpm: wpm)
        let dah = dit * 3
        let symbolGap = dit
        let charGap = dit * 3
        let wordGap = dit * 7

        for (index, symbol) in symbols.enumerated() {
            switch symbol {
            case .dit:
                try torchOn(brightness: brightness)
                try await Task.sleep(nanoseconds: dit)
                try torchOff()
                if index < symbols.count - 1 {
                    let next = symbols[index + 1]
                    if case .dit = next {
                        try await Task.sleep(nanoseconds: symbolGap)
                    } else if case .dah = next {
                        try await Task.sleep(nanoseconds: symbolGap)
                    }
                }

            case .dah:
                try torchOn(brightness: brightness)
                try await Task.sleep(nanoseconds: dah)
                try torchOff()
                if index < symbols.count - 1 {
                    let next = symbols[index + 1]
                    if case .dit = next {
                        try await Task.sleep(nanoseconds: symbolGap)
                    } else if case .dah = next {
                        try await Task.sleep(nanoseconds: symbolGap)
                    }
                }

            case .charGap:
                try await Task.sleep(nanoseconds: charGap - symbolGap)

            case .wordGap:
                try await Task.sleep(nanoseconds: wordGap - symbolGap)
            }

            try Task.checkCancellation()
        }

        try torchOff()
    }

    // MARK: - 강제 종료
    func stop() throws {
        try torchOff()
    }
}
