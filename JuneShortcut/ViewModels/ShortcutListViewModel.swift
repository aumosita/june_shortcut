import Foundation
import Combine

@MainActor
final class ShortcutListViewModel: ObservableObject {
    @Published var entries: [ShortcutEntry] = []
    @Published var selectedEntryID: UUID?

    private let persistence = PersistenceService.shared
    private let hotkeyService = HotkeyService.shared

    var selectedEntry: ShortcutEntry? {
        entries.first { $0.id == selectedEntryID }
    }

    func load() {
        entries = persistence.load()
        rebindHotkeys()
    }

    func save() {
        persistence.save(entries)
        rebindHotkeys()
    }

    func addEntry(_ entry: ShortcutEntry) {
        entries.append(entry)
        save()
    }

    func updateEntry(_ entry: ShortcutEntry) {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[index] = entry
        save()
    }

    func deleteEntry(id: UUID) {
        entries.removeAll { $0.id == id }
        if selectedEntryID == id {
            selectedEntryID = nil
        }
        save()
    }

    func toggleEntry(id: UUID) {
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }
        entries[index].isEnabled.toggle()
        save()
    }

    func conflictingEntry(for combo: KeyCombo, excluding id: UUID? = nil) -> ShortcutEntry? {
        entries.first { entry in
            entry.id != id && entry.keyCombo == combo && entry.isEnabled
        }
    }

    private func rebindHotkeys() {
        hotkeyService.rebindAll(entries: entries)
    }
}
