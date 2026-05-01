//
//  TransmitView.swift
//  AldisLamp
//
//  Created by 박세진 on 5/1/26.
//

import SwiftUI

struct TransmitView: View {
    @Bindable var viewModel: TransmitViewModel
    @State private var signalPressed: Bool = false

    var body: some View {
        VStack(spacing: 16) {

            // MARK: - 모스 시각화
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        Text(viewModel.morseDisplayString.isEmpty ? "· — · —" : viewModel.morseDisplayString)
                            .font(.system(.title3, design: .monospaced))
                            .foregroundStyle(viewModel.morseDisplayString.isEmpty ? .orange.opacity(0.3) : .orange)
                    }
                    Button {
                        viewModel.clear()
                    } label: {
                        Image(systemName: "xmark.circle")
                            .font(.title3)
                            .foregroundStyle(.orange.opacity(0.6))
                    }
                }

                Text(viewModel.translatedText.isEmpty ? "—" : viewModel.translatedText)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.orange.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .glassCard()
            .padding(.horizontal)

            // MARK: - SIGNAL 버튼
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(signalPressed ? 0.3 : 0.08))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange, lineWidth: 1)
                    VStack(spacing: 8) {
                        Text("SIGNAL")
                            .font(.system(.title, design: .monospaced, weight: .bold))
                            .foregroundStyle(.orange)
                        Text(signalPressed ? "●" : "○")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.orange.opacity(0.6))
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !signalPressed {
                                signalPressed = true
                                viewModel.signalBegan()
                            }
                        }
                        .onEnded { _ in
                            signalPressed = false
                            viewModel.signalEnded()
                        }
                )
                .disabled(viewModel.isTransmitting)

            // MARK: - 텍스트 입력
            TextField("ENTER MESSAGE", text: $viewModel.inputText)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.orange)
                .tint(.orange)
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.orange, lineWidth: 1)
                }
                .padding(.horizontal)
                .disabled(viewModel.isTransmitting)

            // MARK: - TRANSMIT 버튼
            Button {
                if viewModel.isTransmitting {
                    viewModel.stopTransmit()
                } else {
                    viewModel.startTransmit()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: viewModel.isTransmitting ? "stop.fill" : "play.fill")
                    Text(viewModel.isTransmitting ? "STOP" : "TRANSMIT")
                        .font(.system(.title3, design: .monospaced, weight: .bold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(.orange)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
            }
            .disabled(signalPressed)

            // MARK: - 프리셋 버튼 (SOS / MAYDAY / CQ)
            HStack(spacing: 8) {
                presetButton("SOS") { viewModel.sendSOS() }
                presetButton("MAYDAY") { viewModel.sendPreset("MAYDAY") }
                presetButton("CQ") { viewModel.sendPreset("CQ") }
            }
            .padding(.horizontal)
            .disabled(viewModel.isTransmitting || signalPressed)

            // MARK: - 에러
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.top)
    }

    // MARK: - 프리셋 버튼
    @ViewBuilder
    private func presetButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(.body, design: .monospaced, weight: .bold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.orange)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .presetButtonStyle()
        }
    }
    
}

#Preview {
    TransmitView(viewModel: .init())
        .preferredColorScheme(.dark)
}
