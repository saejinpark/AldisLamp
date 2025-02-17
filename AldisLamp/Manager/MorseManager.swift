import Foundation

class MorseManager {
    static let shared = MorseManager()
    private let systemManager = SystemManager.shared
    
    func convertToMorse(_ text: String) -> String {
        return text.uppercased().compactMap { Morse.morseDict[$0] }.joined(separator: " ")
    }
    
    func playMorseCode(from text: String) {
        let code = convertToMorse(text)
        playMorseCode(code)
    }
    
    func playMorseCode(_ code: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            for char in code {
                switch char {
                case ".":
                    self.flash(duration: self.systemManager.morseSpeed)
                case "-":
                    self.flash(duration: self.systemManager.morseSpeed * 3)
                case " ":
                    Thread.sleep(forTimeInterval: self.systemManager.morseSpeed * 2)
                default:
                    break
                }
            }
        }
    }
    
    private func flash(duration: TimeInterval) {
        DispatchQueue.main.async {
            self.systemManager.isOn = true
        }
        Thread.sleep(forTimeInterval: duration)
        DispatchQueue.main.async {
            self.systemManager.isOn = false
        }
        Thread.sleep(forTimeInterval: self.systemManager.morseSpeed)
    }
}
