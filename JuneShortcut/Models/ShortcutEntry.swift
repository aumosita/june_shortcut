import Foundation

struct ShortcutEntry: Codable, Identifiable {
    let id: UUID
    var keyCombo: KeyCombo
    var targets: [AppTarget]
    var isEnabled: Bool

    init(id: UUID = UUID(), keyCombo: KeyCombo, targets: [AppTarget] = [], isEnabled: Bool = true) {
        self.id = id
        self.keyCombo = keyCombo
        self.targets = targets
        self.isEnabled = isEnabled
    }

    var displayName: String {
        if targets.isEmpty { return "앱 없음" }
        if targets.count == 1 { return targets[0].displayName }
        return "\(targets[0].displayName) 외 \(targets.count - 1)개"
    }
}
