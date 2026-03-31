import SwiftUI

struct MenuBarView: View {
    @ObservedObject var viewModel: MenuBarViewModel
    @ObservedObject var shortcutListVM: ShortcutListViewModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("JuneShortcut")
                    .font(.headline)
                Spacer()
                Circle()
                    .fill(viewModel.isGlobalEnabled ? Color.green : Color.secondary)
                    .frame(width: 8, height: 8)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)

            Divider()

            if shortcutListVM.entries.isEmpty {
                Text("등록된 단축키 없음")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
            } else {
                ForEach(shortcutListVM.entries.prefix(10)) { entry in
                    HStack {
                        Image(systemName: entry.isEnabled ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(entry.isEnabled ? .accentColor : .secondary)
                            .font(.caption)
                        Text(entry.displayName)
                            .font(.subheadline)
                            .lineLimit(1)
                        Spacer()
                        Text(entry.keyCombo.displayString)
                            .font(.caption.monospaced())
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 2)
                }
            }

            Divider()

            Toggle(viewModel.isGlobalEnabled ? "전체 활성" : "전체 비활성", isOn: Binding(
                get: { viewModel.isGlobalEnabled },
                set: { _ in viewModel.toggleGlobal() }
            ))
            .toggleStyle(.switch)
            .controlSize(.small)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)

            Divider()

            Button {
                openWindow(id: "settings")
                NSApp.activate(ignoringOtherApps: true)
            } label: {
                Label("설정 열기...", systemImage: "gear")
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)

            Button {
                NSApp.terminate(nil)
            } label: {
                Label("종료", systemImage: "power")
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .padding(.bottom, 4)
        }
        .frame(width: 260)
    }
}
