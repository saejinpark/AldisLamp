//
//  MorseDecoder.swift
//  AldisLamp
//
//  Created by 박세진 on 5/2/26.
//

import Foundation

struct MorseDecoder {

    private static let reverseTable: [[MorseSymbol]: Character] = {
        Dictionary(uniqueKeysWithValues: MorseTable.table.map { ($1, $0) })
    }()

    // MARK: - 디코딩
    static func decode(_ symbols: [MorseSymbol]) -> String {
        var result = ""
        var current: [MorseSymbol] = []

        for symbol in symbols {
            switch symbol {
            case .dit, .dah:
                current.append(symbol)
            case .charGap:
                if let char = reverseTable[current] {
                    result.append(char)
                }
                current = []
            case .wordGap:
                if let char = reverseTable[current] {
                    result.append(char)
                }
                current = []
                result.append(" ")
            }
        }

        // 마지막 문자 처리
        if let char = reverseTable[current] {
            result.append(char)
        }

        return result
    }
}
