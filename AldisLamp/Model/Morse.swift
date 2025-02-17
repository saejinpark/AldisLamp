import Foundation

struct Morse: Identifiable, Hashable {
    
    let id = UUID()
    let letter: String
    let code: String
    
    static let morseDict: [Character: String] = [
        "A": ".-", "B": "-...", "C": "-.-.", "D": "-..",
        "E": ".", "F": "..-.", "G": "--.", "H": "....",
        "I": "..", "J": ".---", "K": "-.-", "L": ".-..",
        "M": "--", "N": "-.", "O": "---", "P": ".--.",
        "Q": "--.-", "R": ".-.", "S": "...", "T": "-",
        "U": "..-", "V": "...-", "W": ".--", "X": "-..-",
        "Y": "-.--", "Z": "--..",
        "1": ".----", "2": "..---", "3": "...--", "4": "....-",
        "5": ".....", "6": "-....", "7": "--...", "8": "---..",
        "9": "----.", "0": "-----"
    ]
    
    static let morseData: [Morse] = [
        Morse(letter: "A", code: ".-"), Morse(letter: "B", code: "-..."), Morse(letter: "C", code: "-.-."), Morse(letter: "D", code: "-.."),
        Morse(letter: "E", code: "."), Morse(letter: "F", code: "..-."), Morse(letter: "G", code: "--."), Morse(letter: "H", code: "...."),
        Morse(letter: "I", code: ".."), Morse(letter: "J", code: ".---"), Morse(letter: "K", code: "-.-"), Morse(letter: "L", code: ".-.."),
        Morse(letter: "M", code: "--"), Morse(letter: "N", code: "-.") , Morse(letter: "O", code: "---"), Morse(letter: "P", code: ".--."),
        Morse(letter: "Q", code: "--.-"), Morse(letter: "R", code: ".-."), Morse(letter: "S", code: "..."), Morse(letter: "T", code: "-"),
        Morse(letter: "U", code: "..-"), Morse(letter: "V", code: "...-"), Morse(letter: "W", code: ".--"), Morse(letter: "X", code: "-..-"),
        Morse(letter: "Y", code: "-.--"), Morse(letter: "Z", code: "--.."),
        Morse(letter: "1", code: ".----"), Morse(letter: "2", code: "..---"), Morse(letter: "3", code: "...--"), Morse(letter: "4", code: "....-"),
        Morse(letter: "5", code: "....."), Morse(letter: "6", code: "-...."), Morse(letter: "7", code: "--..."), Morse(letter: "8", code: "---.."),
        Morse(letter: "9", code: "----."), Morse(letter: "0", code: "-----")
    ]
    
    
    static func convertToMorse(_ text: String) -> String {
        return text.uppercased().compactMap { morseDict[$0] }.joined(separator: " ")
    }
}

