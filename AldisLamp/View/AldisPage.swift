//
//  AldisPage.swift
//  AldisLamp
//
//  Created by 박세진 on 2/16/25.
//

import SwiftUI

struct AldisPage: View {
    @ObservedObject var systemManager = SystemManager.shared
    @State private var selectedMode: FlashLightMode = .pressAndHold
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if selectedMode == .pressAndHold {
                        Circle()
                            .fill(systemManager.isOn ? Color.yellow : Color.gray)
                            .overlay {
                                Text(systemManager.isOn ? "켜짐" : "꺼짐")
                                    .font(.largeTitle)
                                    .foregroundColor(systemManager.isOn ? .white : .black)
                                    .bold()
                            }
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        systemManager.isOn = true
                                    }
                                    .onEnded { _ in
                                        systemManager.isOn = false
                                    }
                            )
                    } else {
                        Button {
                            systemManager.isOn.toggle()
                        } label: {
                            Rectangle()
                                .fill(systemManager.isOn ? Color.yellow : Color.gray)
                                .frame(width: 300, height: 300)
                        }
                        .animation(nil, value: systemManager.isOn)
                    }
                    Spacer()
                }
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Spacer()
                }
                ToolbarItem(placement: .principal) {
                    Picker("Flashlight Mode", selection: $selectedMode) {
                        ForEach(FlashLightMode.allCases, id: \.self) { mode in
                            if mode == .pressAndHold {
                                Text("Press and Hold").tag(mode)
                            } else {
                                Text("Toggle").tag(mode)
                            }
                        }
                    }.pickerStyle(.segmented)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    AldisPage()
        .preferredColorScheme(.dark)
}
