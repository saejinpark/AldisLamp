//
//  SettingsView.swift
//  AldisLamp
//
//  Created by 박세진 on 5/1/26.
//

import SwiftUI

struct SettingsView: View {

    var viewModel: TransmitViewModel

    var body: some View {
        NavigationStack {
            List {

                // MARK: - 송출 설정
                Section("TRANSMISSION") {

                    // WPM
                    VStack(alignment: .leading, spacing: 8) {
                        LabeledContent("SPEED", value: "\(viewModel.wpm) WPM")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.orange)
                        Slider(value: Binding(
                            get: { Double(viewModel.wpm) },
                            set: { viewModel.wpm = Int($0) }
                        ), in: 5...30, step: 1)
                            .tint(.orange)
                        HStack {
                            Text("5")
                            Spacer()
                            Text("30")
                        }
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.orange.opacity(0.4))
                    }

                    // 밝기
                    VStack(alignment: .leading, spacing: 8) {
                        LabeledContent("TORCH BRIGHTNESS", value: "\(Int(viewModel.brightness * 100))%")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.orange)
                        Slider(value: Binding(
                            get: { Double(viewModel.brightness) },
                            set: { viewModel.brightness = Float($0) }
                        ), in: 0.1...1.0, step: 0.1)
                            .tint(.orange)
                        HStack {
                            Text("10%")
                            Spacer()
                            Text("100%")
                        }
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.orange.opacity(0.4))
                    }

                    // 반복 송출
                    Toggle(isOn: Binding(
                        get: { viewModel.repeatTransmit },
                        set: { viewModel.repeatTransmit = $0 }
                    )) {
                        LabeledContent {
                            EmptyView()
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("REPEAT")
                                    .font(.system(.body, design: .monospaced, weight: .bold))
                                Text("반복 송출")
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .tint(.orange)
                }

                // MARK: - 화면 설정
                Section("DISPLAY") {
                    Toggle(isOn: Binding(
                        get: { viewModel.preventSleep },
                        set: { viewModel.preventSleep = $0 }
                    )) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("PREVENT SLEEP")
                                .font(.system(.body, design: .monospaced, weight: .bold))
                            Text("송출 중 화면 꺼짐 방지")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.orange)
                }

                // MARK: - 피드백
                Section("FEEDBACK") {
                    Toggle(isOn: Binding(
                        get: { viewModel.hapticFeedback },
                        set: { viewModel.hapticFeedback = $0 }
                    )) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("HAPTIC")
                                .font(.system(.body, design: .monospaced, weight: .bold))
                            Text("진동 피드백")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.orange)

                    Toggle(isOn: Binding(
                        get: { viewModel.soundFeedback },
                        set: { viewModel.soundFeedback = $0 }
                    )) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("SOUND")
                                .font(.system(.body, design: .monospaced, weight: .bold))
                            Text("삑 소리 피드백")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.orange)
                }

                // MARK: - 정보
                Section("INFO") {
                    LabeledContent("STANDARD", value: "ITU-R M.1677")
                        .font(.system(.caption, design: .monospaced))
                    LabeledContent("VERSION", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")
                        .font(.system(.caption, design: .monospaced))
                }
            }
            .navigationTitle("SETTINGS")
        }
    }
}

#Preview {
    SettingsView(viewModel: .init())
        .preferredColorScheme(.dark)
}
