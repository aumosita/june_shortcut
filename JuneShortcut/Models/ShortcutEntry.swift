import Foundation

struct ShortcutEntry: Codable, Identifiable {
    let id: UUID
    var keyCombo: KeyCombo
    var targets: [AppTarget]
    var isEnabled: Bool
    var label: String

    init(id: UUID = UUID(), keyCombo: KeyCombo, targets: [AppTarget] = [], isEnabled: Bool = true, label: String = "") {
        self.id = id
        self.keyCombo = keyCombo
        self.targets = targets
        self.isEnabled = isEnabled
        self.label = label
    }
}
