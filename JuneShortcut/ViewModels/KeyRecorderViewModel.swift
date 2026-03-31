import Foundation

enum KeyRecorderState: Equatable {
    case idle
    case recording
    case recorded(KeyCombo)
}

@MainActor
final class KeyRecorderViewModel: ObservableObject {
    @Published var state: KeyRecorderState = .idle
    @Published var currentKeyCombo: KeyCombo?

    func startRecording() {
        state = .recording
    }

    func stopRecording() {
        state = currentKeyCombo.map { .recorded($0) } ?? .idle
    }

    func recordKeyCombo(_ combo: KeyCombo) {
        guard combo.hasModifiers else { return }
        currentKeyCombo = combo
        state = .recorded(combo)
    }

    func clear() {
        currentKeyCombo = nil
        state = .idle
    }

    var displayText: String {
        switch state {
        case .idle:
            return "단축키를 설정하세요"
        case .recording:
            return "키 조합을 입력하세요..."
        case .recorded(let combo):
            return combo.displayString
        }
    }
}
