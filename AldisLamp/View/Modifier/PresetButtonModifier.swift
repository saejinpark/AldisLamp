//
//  Untitled.swift
//  AldisLamp
//
//  Created by 박세진 on 5/2/26.
//

import SwiftUI

struct PresetButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.body, design: .monospaced, weight: .bold))
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.orange)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

extension View {
    func presetButtonStyle() -> some View {
        modifier(PresetButtonModifier())
    }
}
