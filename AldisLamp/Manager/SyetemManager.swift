//
//  SyetemManager.swift
//  AldisLamp
//
//  Created by 박세진 on 2/16/25.
//

import Foundation

class SystemManager: ObservableObject {
    static let shared = SystemManager()
    private let userDefaults = UserDefaults.standard
    private let lampManager = LampManager()
    private let hapticManager = HapticManager()
    
    private enum Keys {
        static let brightness = "brightness"
        static let hapticEnabled = "HapticEnabled"
        static let morseSpeed = "MorseSpeed"
    }
    
    @Published var brightness: Float {
        didSet {
            userDefaults.set(brightness, forKey: Keys.brightness)
            lampManager.updateBrightness(level: brightness)
        }
    }
    
    @Published var isHapticEnabled: Bool {
        didSet {
            userDefaults.set(isHapticEnabled, forKey: Keys.hapticEnabled)
            if !isHapticEnabled { hapticManager.stopHaptic() }
        }
    }
    
    @Published var morseSpeed: TimeInterval {
        didSet { userDefaults.set(morseSpeed, forKey: Keys.morseSpeed) }
    }
    
    @Published var isOn: Bool = false {
        didSet {
            if isOn {
                lampManager.turnOn()
                if isHapticEnabled { hapticManager.startContinuousHaptic() }
            } else {
                lampManager.turnOff()
                hapticManager.stopHaptic()
            }
        }
    }
    
    init() {
        self.brightness = userDefaults.float(forKey: Keys.brightness) == 0 ? 1.0 : userDefaults.float(forKey: Keys.brightness)
        self.isHapticEnabled = userDefaults.bool(forKey: Keys.hapticEnabled)
        self.morseSpeed = userDefaults.double(forKey: Keys.morseSpeed) == 0 ? 0.2 : userDefaults.double(forKey: Keys.morseSpeed)
    }
}
