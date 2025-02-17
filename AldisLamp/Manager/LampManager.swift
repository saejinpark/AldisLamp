//
//  LampManager.swift
//  AldisLamp
//
//  Created by 박세진 on 2/15/25.
//

import AVFoundation
import CoreHaptics

class LampManager: ObservableObject {
    private let device = AVCaptureDevice.default(for: .video)
    
    func turnOn() {
        guard let device = device, device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            try device.setTorchModeOn(level: SystemManager.shared.brightness)
            device.unlockForConfiguration()
        } catch {
            print("손전등을 켤 수 없습니다.")
        }
    }
    
    func turnOff() {
        guard let device = device, device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = .off
            device.unlockForConfiguration()
        } catch {
            print("손전등을 끌 수 없습니다.")
        }
    }
    
    func updateBrightness(level: Float) {
        guard let device = device, device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if device.torchMode == .on {
                try device.setTorchModeOn(level: level)
            }
            device.unlockForConfiguration()
        } catch {
            print("밝기 조절 실패: \(error.localizedDescription)")
        }
    }
}
