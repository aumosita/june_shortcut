import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: ShortcutListViewModel
    @State private var showingAddSheet = false
    @State private var editingEntryID: UUID?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("단축키 설정")
                    .font(.title2.bold())
                Spacer()
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .padding()

            Divider()

            if viewModel.entries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "command.square")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("등록된 단축키가 없습니다")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("+ 버튼을 눌러 새 단축키를 추가하세요")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.entries) { entry in
                        ShortcutRowView(
                            entry: entry,
                            onToggle: { viewModel.toggleEntry(id: entry.id) },
                            onDelete: { viewModel.deleteEntry(id: entry.id) }
                        )
                        .contentShape(Rectangle())
                        .onTapGesture(count: 2) {
                            editingEntryID = entry.id
                        }
                    }
                }
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        .sheet(isPresented: $showingAddSheet) {
            ShortcutEditView(listViewModel: viewModel, entryID: nil)
        }
        .sheet(item: $editingEntryID) { id in
            ShortcutEditView(listViewModel: viewModel, entryID: id)
        }
    }
}

extension UUID: @retroactive Identifiable {
    public var id: UUID { self }
}
