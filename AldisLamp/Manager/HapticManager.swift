//
//  HapticManager.swift
//  AldisLamp
//
//  Created by 박세진 on 2/16/25.
//

import Foundation
import CoreHaptics

class HapticManager {
    private var hapticEngine: CHHapticEngine?
    private var continuousPlayer: CHHapticPatternPlayer?
    private var isHapticPlaying = false
    
    init() {
        prepareHapticEngine()
    }
    
    private func prepareHapticEngine() {
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("햅틱 엔진 초기화 실패: \(error.localizedDescription)")
        }
    }
    
    func startContinuousHaptic() {
        guard let engine = hapticEngine, !isHapticPlaying else { return }
        isHapticPlaying = true
        do {
            let pattern = try CHHapticPattern(events: [
                CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 0, duration: .infinity)
            ], parameters: [])
            continuousPlayer = try engine.makePlayer(with: pattern)
            try continuousPlayer?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("햅틱 실행 실패: \(error.localizedDescription)")
        }
    }
    
    func stopHaptic() {
        guard isHapticPlaying else { return }
        isHapticPlaying = false
        do {
            try continuousPlayer?.stop(atTime: CHHapticTimeImmediate)
        } catch {
            print("햅틱 중지 실패: \(error.localizedDescription)")
        }
    }
}
