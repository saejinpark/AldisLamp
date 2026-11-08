import SwiftUI

/// Design tokens shared by every screen. Mirrors the "Aldis Lamp" design system.
enum DS {
    /// Spacing scale, in points.
    enum Space {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }

    /// Corner radii, in points.
    enum Radius {
        static let chip: CGFloat = 6
        static let sm: CGFloat = 8
        static let control: CGFloat = 10
        static let card: CGFloat = 12
        static let key: CGFloat = 18
    }
}

extension Color {
    // Light
    /// The lamp's light: lens when lit, progress, highlighted characters.
    static let beam = Color(red: 1.0, green: 0.93, blue: 0.72)
    // Brass
    /// Housing mid-tone and the manual key at rest.
    static let brass = Color(red: 0.72, green: 0.55, blue: 0.25)
    /// Accent: primary buttons, tint, highlights on the housing.
    static let brassLight = Color(red: 0.92, green: 0.78, blue: 0.45)
    /// Housing shadow side, bezel, pressed key.
    static let brassDark = Color(red: 0.42, green: 0.30, blue: 0.12)
    // Surfaces
    /// Page background.
    static let deck = Color(red: 0.07, green: 0.09, blue: 0.12)
    /// Fallback fill for panels where glass cannot be used; glass panels sit directly on the deck.
    static let deckRaised = Color(red: 0.12, green: 0.15, blue: 0.19)
    /// Cold ambient light in the deck background, bottom right; gives the glass something to refract.
    static let seaGlow = Color(red: 0.11, green: 0.20, blue: 0.32)
    // Ink
    /// Primary text on deck and deckRaised.
    static let ink = Color(red: 0.95, green: 0.93, blue: 0.90)
    /// Secondary text and captions on deck and deckRaised.
    static let inkMuted = Color(red: 0.60, green: 0.64, blue: 0.68)
    /// Characters the Morse table does not know.
    static let signalError = Color(red: 1.0, green: 0.45, blue: 0.42)
}
