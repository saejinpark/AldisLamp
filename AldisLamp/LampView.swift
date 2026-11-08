import SwiftUI

/// The signal lamp: a brass-rimmed lens that glows when the shutter is open.
struct LampView: View {
    var isOn: Bool

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            ZStack {
                // Light spill onto the surroundings.
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.beam.opacity(isOn ? 0.55 : 0), .clear],
                            center: .center, startRadius: size * 0.3, endRadius: size * 0.75
                        )
                    )
                    .frame(width: size * 1.5, height: size * 1.5)
                    .blur(radius: 10)

                // Brass housing.
                Circle()
                    .fill(
                        AngularGradient(
                            colors: [.brassDark, .brass, .brassLight, .brass, .brassDark, .brass, .brassDark],
                            center: .center
                        )
                    )
                    .frame(width: size, height: size)
                    .shadow(color: .black.opacity(0.6), radius: 12, y: 8)

                // Lens bezel.
                Circle()
                    .strokeBorder(Color.brassDark, lineWidth: size * 0.025)
                    .frame(width: size * 0.84, height: size * 0.84)

                // Lens.
                Circle()
                    .fill(
                        RadialGradient(
                            colors: isOn
                                ? [.white, .beam, Color.beam.opacity(0.85)]
                                : [Color(white: 0.28), Color(white: 0.14), Color(white: 0.08)],
                            center: UnitPoint(x: 0.42, y: 0.38),
                            startRadius: 0, endRadius: size * 0.45
                        )
                    )
                    .frame(width: size * 0.8, height: size * 0.8)
                    .overlay(fresnelRings(size: size * 0.8))
                    .overlay(
                        // Glass highlight.
                        Ellipse()
                            .fill(LinearGradient(colors: [.white.opacity(0.35), .clear], startPoint: .top, endPoint: .bottom))
                            .frame(width: size * 0.5, height: size * 0.22)
                            .offset(y: -size * 0.24)
                    )
                    .shadow(color: isOn ? Color.beam.opacity(0.9) : .clear, radius: size * 0.12)

                // Shutter louvres close over the lens when off.
                shutter(size: size * 0.8)
                    .opacity(isOn ? 0 : 1)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .animation(.easeOut(duration: 0.05), value: isOn)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityLabel(isOn ? "램프 켜짐" : "램프 꺼짐")
    }

    private func fresnelRings(size: CGFloat) -> some View {
        ZStack {
            ForEach(1..<5) { i in
                Circle()
                    .strokeBorder(Color.black.opacity(isOn ? 0.08 : 0.35), lineWidth: 1)
                    .frame(width: size * CGFloat(i) / 5, height: size * CGFloat(i) / 5)
            }
        }
    }

    private func shutter(size: CGFloat) -> some View {
        VStack(spacing: size * 0.02) {
            ForEach(0..<7) { _ in
                RoundedRectangle(cornerRadius: 2)
                    .fill(LinearGradient(colors: [Color(white: 0.22), Color(white: 0.1)], startPoint: .top, endPoint: .bottom))
                    .frame(height: size * 0.12)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
