//
//  MorsePage.swift
//  AldisLamp
//
//  Created by 박세진 on 2/16/25.
//

import SwiftUI

struct MorsePage: View {
    @State private var textInput = ""
    @State private var morseOutput = ""
    
    @State private var isPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                TextField("글자를 입력해주세요", text: $textInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.asciiCapable)
                    .onChange(of: textInput, initial: true) { newValue,arg  in
                        textInput = newValue.uppercased().filter { "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".contains($0) }
                        morseOutput = MorseManager.shared.convertToMorse(textInput)
                    }
                
                Text("모스 코드:")
                Text("\(morseOutput)")
                
                Section {
                    Button {
                        MorseManager.shared.playMorseCode(from: textInput)
                    } label: {
                        Label("출력하기", systemImage: "antenna.radiowaves.left.and.right")
                    }
                }
                
            }
            .navigationTitle("모스 코드")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresented.toggle()
                    } label: {
                        Label("도움말", systemImage: "questionmark.circle")
                    }
                }
            }
            .listStyle(.plain)
            .sheet(isPresented: $isPresented) {
                
                List {
                    Section("신호") {
                        ForEach(Signal.signalData, id: \.self) { signal in
                            HStack {
                                Text("\(signal.letter)")
                                    .font(.headline)
                                    .frame(width: 80, alignment: .leading)
                                    
                                Divider()
                                Text("\(signal.code)")
                                    .frame(width: 80, alignment: .leading)
                                Divider()
                                Text("\(signal.meaning)")
                            }
                        }
                    }
                    Section("알파벳") {
                        ForEach(Morse.morseData, id: \.self) { morse in
                            HStack {
                                Text("\(morse.letter)")
                                    .font(.headline)
                                    .frame(width: 120, alignment: .leading)
                                Divider()
                                Text("\(morse.code)")
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    MorsePage()
        .preferredColorScheme(.dark)
}
