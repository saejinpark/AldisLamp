//
//  MorseEncoder.swift
//  AldisLamp
//
//  Created by 박세진 on 5/1/26.
//

import Foundation

struct MorseEncoder {

    // MARK: - 인코딩
    static func encode(_ text: String) -> [MorseSymbol] {
        let words = text.uppercased().split(separator: " ", omittingEmptySubsequences: true)
        var result: [MorseSymbol] = []

        for (wordIndex, word) in words.enumerated() {
            for (charIndex, char) in word.enumerated() {
                guard let symbols = MorseTable.table[char] else { continue }

                result.append(contentsOf: symbols)

                if charIndex < word.count - 1 {
                    result.append(.charGap)
                }
            }
            if wordIndex < words.count - 1 {
                result.append(.wordGap)
            }
        }

        return result
    }

    // MARK: - 디스플레이 문자열
    static func toDisplayString(_ symbols: [MorseSymbol]) -> String {
        symbols.map { symbol in
            switch symbol {
            case .dit:     return "·"
            case .dah:     return "—"
            case .charGap: return " "
            case .wordGap: return " / "
            }
        }.joined()
    }
}
