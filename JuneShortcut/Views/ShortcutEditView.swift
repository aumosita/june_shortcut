import SwiftUI

struct ShortcutEditView: View {
    @ObservedObject var listViewModel: ShortcutListViewModel
    let entryID: UUID?

    @StateObject private var keyRecorderVM = KeyRecorderViewModel()
    @State private var targets: [AppTarget] = []
    @State private var showingAppPicker = false
    @State private var showingConflictAlert = false
    @State private var conflictDisplayName = ""
    @Environment(\.dismiss) private var dismiss

    private var isEditing: Bool { entryID != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(isEditing ? "단축키 편집" : "새 단축키 추가")
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 6) {
                Text("단축키")
                    .font(.subheadline.bold())
                KeyRecorderView(viewModel: keyRecorderVM)
                    .frame(height: 28)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("앱")
                        .font(.subheadline.bold())
                    Spacer()
                    Button("앱 선택...") {
                        showingAppPicker = true
                    }
                }

                if targets.isEmpty {
                    Text("선택된 앱이 없습니다")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 8)
                } else {
                    ForEach(targets) { target in
                        HStack {
                            AppIconView(path: target.path)
                            Text(target.displayName)
                            Spacer()
                            Button {
                                targets.removeAll { $0.id == target.id }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }

            Spacer()

            HStack {
                Spacer()
                Button("취소") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("저장") {
                    saveEntry()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(keyRecorderVM.currentKeyCombo == nil || targets.isEmpty)
            }
        }
        .padding(20)
        .frame(width: 400, height: 380)
        .sheet(isPresented: $showingAppPicker) {
            AppPickerView(selectedTargets: $targets)
        }
        .alert("단축키 충돌", isPresented: $showingConflictAlert) {
            Button("대체") { forceSaveEntry() }
            Button("취소", role: .cancel) {}
        } message: {
            Text("이 단축키는 이미 '\(conflictDisplayName)'에 할당되어 있습니다. 대체하시겠습니까?")
        }
        .onAppear {
            if let id = entryID, let entry = listViewModel.entries.first(where: { $0.id == id }) {
                targets = entry.targets
                keyRecorderVM.currentKeyCombo = entry.keyCombo
                keyRecorderVM.state = .recorded(entry.keyCombo)
            }
        }
    }

    private func saveEntry() {
        guard let combo = keyRecorderVM.currentKeyCombo else { return }

        if let conflict = listViewModel.conflictingEntry(for: combo, excluding: entryID) {
            conflictDisplayName = conflict.displayName
            showingConflictAlert = true
            return
        }

        forceSaveEntry()
    }

    private func forceSaveEntry() {
        guard let combo = keyRecorderVM.currentKeyCombo else { return }

        if let conflict = listViewModel.conflictingEntry(for: combo, excluding: entryID) {
            var updated = conflict
            updated.isEnabled = false
            listViewModel.updateEntry(updated)
        }

        if let id = entryID {
            listViewModel.updateEntry(ShortcutEntry(id: id, keyCombo: combo, targets: targets, isEnabled: true))
        } else {
            listViewModel.addEntry(ShortcutEntry(keyCombo: combo, targets: targets))
        }

        dismiss()
    }
}

struct AppIconView: View {
    let path: String

    var body: some View {
        Image(nsImage: NSWorkspace.shared.icon(forFile: path))
            .resizable()
            .frame(width: 20, height: 20)
    }
}
