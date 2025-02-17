//
//  SettingPage.swift
//  AldisLamp
//
//  Created by 박세진 on 2/16/25.
//

import SwiftUI

struct SettingPage: View {
    
    @ObservedObject var systemManager = SystemManager.shared
    
    var body: some View {
      NavigationStack {
        Form {
            Section(header: Text("햅틱"), footer: Text("햅틱 기능을 활성화하거나 비활성화할 수 있습니다.")) {
                Toggle("햅틱 활성화", isOn: $systemManager.isHapticEnabled)
            }
            
            Section(header: Text("밝기"), footer: Text("손전등의 밝기를 조절합니다. 0.1에서 1.0까지 설정 가능합니다.")) {
                Slider(value: $systemManager.brightness, in: 0.1...1.0, step: 0.1) {
                    Text("밝기 조절")
                }
                Text("현재 밝기: \(String(format: "%.1f", systemManager.brightness))")
            }
            
            Section(header: Text("모스 코드 속도"), footer: Text("모스 코드 점멸 속도를 설정합니다. 값이 낮을수록 빠르게 점멸됩니다.")) {
                Slider(value: $systemManager.morseSpeed, in: 0.1...1.0, step: 0.1) {
                    Text("속도 조절")
                }
                Text("현재 속도: \(String(format: "%.1f", systemManager.morseSpeed)) 초")
            }
        }
        .navigationTitle("설정")
      }
    }
}

#Preview {
    SettingPage()
}
