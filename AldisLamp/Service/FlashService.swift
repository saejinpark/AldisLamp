//
//  FlashService.swift
//  AldisLamp
//
//  Created by 박세진 on 5/1/26.
//

import AVFoundation
import UIKit

actor FlashService {

    private let device: AVCaptureDevice? = AVCaptureDevice.default(for: .video)

    private func ditDuration(wpm: Int) -> UInt64 {
        UInt64(1_200_000_000 / wpm)
    }

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

    func transmit(symbols: [MorseSymbol], wpm: Int, brightness: Float, soundFeedback: Bool, hapticFeedback: Bool) async throws {
        let dit = ditDuration(wpm: wpm)
        let dah = dit * 3
        let symbolGap = dit
        let charGap = dit * 3
        let wordGap = dit * 7

        for (index, symbol) in symbols.enumerated() {
            switch symbol {
            case .dit:
                try torchOn(brightness: brightness)
                if soundFeedback { await MainActor.run { SoundService.dit() } }
                if hapticFeedback { await MainActor.run { UIImpactFeedbackGenerator(style: .light).impactOccurred() } }
                try await Task.sleep(nanoseconds: dit)
                try torchOff()
                if index < symbols.count - 1 {
                    let next = symbols[index + 1]
                    if case .dit = next { try await Task.sleep(nanoseconds: symbolGap) }
                    else if case .dah = next { try await Task.sleep(nanoseconds: symbolGap) }
                }

            case .dah:
                try torchOn(brightness: brightness)
                if soundFeedback { await MainActor.run { SoundService.dah(wpm: wpm) } }
                if hapticFeedback { await MainActor.run { UIImpactFeedbackGenerator(style: .medium).impactOccurred() } }
                try await Task.sleep(nanoseconds: dah)
                try torchOff()
                if index < symbols.count - 1 {
                    let next = symbols[index + 1]
                    if case .dit = next { try await Task.sleep(nanoseconds: symbolGap) }
                    else if case .dah = next { try await Task.sleep(nanoseconds: symbolGap) }
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

    func stop() throws {
        try torchOff()
    }
}
