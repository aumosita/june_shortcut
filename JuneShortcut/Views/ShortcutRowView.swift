import SwiftUI

struct ShortcutRowView: View {
    let entry: ShortcutEntry
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Toggle("", isOn: Binding(
                get: { entry.isEnabled },
                set: { _ in onToggle() }
            ))
            .toggleStyle(.switch)
            .controlSize(.small)
            .labelsHidden()

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.displayName)
                    .font(.body)
                    .foregroundColor(entry.isEnabled ? .primary : .secondary)

                HStack(spacing: 4) {
                    ForEach(entry.targets.prefix(3)) { target in
                        Image(nsImage: NSWorkspace.shared.icon(forFile: target.path))
                            .resizable()
                            .frame(width: 14, height: 14)
                    }
                    if entry.targets.count > 3 {
                        Text("+\(entry.targets.count - 3)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            Text(entry.keyCombo.displayString)
                .font(.system(.body, design: .rounded).bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.secondary.opacity(0.15))
                )

            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}
