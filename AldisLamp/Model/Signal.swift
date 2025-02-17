//
//  Signal.swift
//  AldisLamp
//
//  Created by 박세진 on 2/17/25.
//
import Foundation

struct Signal: Identifiable, Hashable {
    
    let id = UUID()
    let letter: String
    let code: String
    let meaning: String
    
    
    static let signalData: [Signal] = [
        Signal(letter: "SOS", code: "...---...", meaning: "Emergency Signal - Universal distress call"),
        Signal(letter: "MAYDAY", code: "-- .- -.-- -.. .- -.--", meaning: "Distress Signal used in voice communication"),
        Signal(letter: "PAN-PAN", code: ".--. .- -. / .--. .- -.", meaning: "Urgency signal for non-life-threatening situations"),
        Signal(letter: "SEELONCE", code: "... . . .-.. --- -. -.-. .", meaning: "Request for radio silence during emergency"),
        Signal(letter: "HELP", code: ".... . .-.. .--.", meaning: "General call for assistance")
            
    ]
}
