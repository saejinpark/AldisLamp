//
//  GlassCardModifier.swift
//  AldisLamp
//
//  Created by 박세진 on 5/2/26.
//

import SwiftUI

struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.orange.opacity(0.05))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCardModifier())
    }
}
