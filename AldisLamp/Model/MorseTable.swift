//
//  MorseTable.swift
//  AldisLamp
//
//  Created by 박세진 on 5/2/26.
//

import Foundation

enum MorseTable {
    static let table: [Character: [MorseSymbol]] = [
        // 영문
        "A": [.dit, .dah],
        "B": [.dah, .dit, .dit, .dit],
        "C": [.dah, .dit, .dah, .dit],
        "D": [.dah, .dit, .dit],
        "E": [.dit],
        "F": [.dit, .dit, .dah, .dit],
        "G": [.dah, .dah, .dit],
        "H": [.dit, .dit, .dit, .dit],
        "I": [.dit, .dit],
        "J": [.dit, .dah, .dah, .dah],
        "K": [.dah, .dit, .dah],
        "L": [.dit, .dah, .dit, .dit],
        "M": [.dah, .dah],
        "N": [.dah, .dit],
        "O": [.dah, .dah, .dah],
        "P": [.dit, .dah, .dah, .dit],
        "Q": [.dah, .dah, .dit, .dah],
        "R": [.dit, .dah, .dit],
        "S": [.dit, .dit, .dit],
        "T": [.dah],
        "U": [.dit, .dit, .dah],
        "V": [.dit, .dit, .dit, .dah],
        "W": [.dit, .dah, .dah],
        "X": [.dah, .dit, .dit, .dah],
        "Y": [.dah, .dit, .dah, .dah],
        "Z": [.dah, .dah, .dit, .dit],
        // 숫자
        "0": [.dah, .dah, .dah, .dah, .dah],
        "1": [.dit, .dah, .dah, .dah, .dah],
        "2": [.dit, .dit, .dah, .dah, .dah],
        "3": [.dit, .dit, .dit, .dah, .dah],
        "4": [.dit, .dit, .dit, .dit, .dah],
        "5": [.dit, .dit, .dit, .dit, .dit],
        "6": [.dah, .dit, .dit, .dit, .dit],
        "7": [.dah, .dah, .dit, .dit, .dit],
        "8": [.dah, .dah, .dah, .dit, .dit],
        "9": [.dah, .dah, .dah, .dah, .dit],
        // 특수문자
        ".": [.dit, .dah, .dit, .dah, .dit, .dah],
        ",": [.dah, .dah, .dit, .dit, .dah, .dah],
        "?": [.dit, .dit, .dah, .dah, .dit, .dit],
        "/": [.dah, .dit, .dit, .dah, .dit],
        "-": [.dah, .dit, .dit, .dit, .dit, .dah],
        "+": [.dit, .dah, .dit, .dah, .dit],
        "=": [.dah, .dit, .dit, .dit, .dah],
        "@": [.dit, .dah, .dah, .dit, .dah, .dit]
    ]
}
