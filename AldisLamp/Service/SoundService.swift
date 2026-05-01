//
//  SoundService.swift
//  AldisLamp
//
//  Created by 박세진 on 5/2/26.
//

import AudioToolbox

struct SoundService {
    static func dit() {
        AudioServicesPlaySystemSound(1057)  // 짧은 삑
    }
    
    static func dah(wpm: Int) {
        let interval = 0.04
        for i in 0..<6 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                AudioServicesPlaySystemSound(1057)
            }
        }
    }
}
