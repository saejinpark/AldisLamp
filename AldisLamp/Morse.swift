import Foundation

/// International Morse code table and timing rules (PARIS standard).
enum Morse {
    static let table: [Character: String] = [
        "A": ".-", "B": "-...", "C": "-.-.", "D": "-..", "E": ".", "F": "..-.",
        "G": "--.", "H": "....", "I": "..", "J": ".---", "K": "-.-", "L": ".-..",
        "M": "--", "N": "-.", "O": "---", "P": ".--.", "Q": "--.-", "R": ".-.",
        "S": "...", "T": "-", "U": "..-", "V": "...-", "W": ".--", "X": "-..-",
        "Y": "-.--", "Z": "--..",
        "0": "-----", "1": ".----", "2": "..---", "3": "...--", "4": "....-",
        "5": ".....", "6": "-....", "7": "--...", "8": "---..", "9": "----.",
        ".": ".-.-.-", ",": "--..--", "?": "..--..", "'": ".----.", "!": "-.-.--",
        "/": "-..-.", "(": "-.--.", ")": "-.--.-", "&": ".-...", ":": "---...",
        ";": "-.-.-.", "=": "-...-", "+": ".-.-.", "-": "-....-", "_": "..--.-",
        "\"": ".-..-.", "$": "...-..-", "@": ".--.-."
    ]

    /// Letters in the order a reference card usually shows them.
    static let referenceOrder: [Character] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,?!/@")

    /// One timing event in a transmission.
    struct Event: Equatable {
        enum Kind: Equatable { case on, off }
        let kind: Kind
        /// Length in dot units.
        let units: Int
        /// Index of the source character this event belongs to, if any.
        let charIndex: Int?
    }

    /// Converts text to a sequence of on/off events.
    /// Dot = 1, dash = 3, gap inside a letter = 1, between letters = 3, between words = 7.
    static func events(for text: String) -> [Event] {
        var result: [Event] = []
        let chars = Array(text.uppercased())
        var previousWasLetter = false

        for (index, ch) in chars.enumerated() {
            if ch == " " {
                if previousWasLetter {
                    // Replace the trailing 3-unit letter gap with a 7-unit word gap.
                    if let last = result.last, last.kind == .off, last.units == 3 {
                        result.removeLast()
                    }
                    result.append(Event(kind: .off, units: 7, charIndex: index))
                }
                previousWasLetter = false
                continue
            }
            guard let code = table[ch] else { continue }
            for (i, symbol) in code.enumerated() {
                result.append(Event(kind: .on, units: symbol == "." ? 1 : 3, charIndex: index))
                if i < code.count - 1 {
                    result.append(Event(kind: .off, units: 1, charIndex: index))
                }
            }
            result.append(Event(kind: .off, units: 3, charIndex: index))
            previousWasLetter = true
        }
        // No gap needed after the final symbol.
        if let last = result.last, last.kind == .off { result.removeLast() }
        return result
    }

    /// Dot length in seconds for a given words-per-minute speed.
    static func dotDuration(wpm: Double) -> TimeInterval {
        1.2 / max(wpm, 1)
    }

    static func code(for ch: Character) -> String? {
        table[Character(ch.uppercased())]
    }

    private static let reverse: [String: Character] = Dictionary(uniqueKeysWithValues: table.map { ($1, $0) })

    /// Looks up the character for a dot/dash string such as "..." (returns nil when unknown).
    static func character(for symbols: String) -> Character? {
        reverse[symbols]
    }
}
