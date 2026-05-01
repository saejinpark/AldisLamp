//
//  MorseSymbol.swift
//  AldisLamp
//
//  Created by 박세진 on 5/2/26.
//
import Foundation

enum MorseSymbol: Equatable, Sendable {
    case dit      // ·  짧은 신호
    case dah      // —  긴 신호
    case charGap  // 문자 간 공백
    case wordGap  // 단어 간 공백
}
