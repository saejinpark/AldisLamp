//
//  ContentView.swift
//  AldisLamp
//
//  Created by 박세진 on 5/1/26.
//

import SwiftUI

struct ContentView: View {

    @State private var viewModel = TransmitViewModel()

    var body: some View {
        TabView {
            TransmitView(viewModel: viewModel)
                .tabItem {
                    Label("MAIN", systemImage: "antenna.radiowaves.left.and.right")
                }
            SettingsView(viewModel: viewModel)
                .tabItem {
                    Label("SETTINGS", systemImage: "gearshape")
                }
        }
        .tint(.orange)
    }
}

#Preview {
    ContentView()
}
