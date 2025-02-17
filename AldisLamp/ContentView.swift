//
//  ContentView.swift
//  AldisLamp
//
//  Created by 박세진 on 2/15/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            AldisPage()
                .tabItem {
                    Label("Aldis", systemImage: "flashlight.on.fill")
                }
            MorsePage()
                .tabItem {
                    Label("Morse", systemImage: "waveform")
                }
            SettingPage()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
