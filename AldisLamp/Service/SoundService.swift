//
//  SoundService.swift
//  AldisLamp
//
//  Created by 박세진 on 5/2/26.
//

import AVFoundation

struct SoundService {

    private static var audioPlayer: AVAudioPlayer?

    // MARK: - 삑 소리
    static func beep() {
        // 시스템 사운드 사용 (1057 = 짧은 삑)
        AudioServicesPlaySystemSound(1057)
    }
}
