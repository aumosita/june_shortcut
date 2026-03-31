import SwiftUI
import AppKit

struct InstalledApp: Identifiable, Hashable {
    let id: String // bundleIdentifier
    let name: String
    let path: String
    let icon: NSImage
}

struct AppPickerView: View {
    @Binding var selectedTargets: [AppTarget]
    @State private var installedApps: [InstalledApp] = []
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    var filteredApps: [InstalledApp] {
        if searchText.isEmpty {
            return installedApps
        }
        return installedApps.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("앱 선택")
                    .font(.headline)
                Spacer()
                Button("기타...") {
                    openFilePicker()
                }
            }
            .padding()

            TextField("앱 검색...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .padding(.bottom, 8)

            List(filteredApps) { app in
                HStack {
                    Image(nsImage: app.icon)
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text(app.name)
                        .lineLimit(1)
                    Spacer()
                    if selectedTargets.contains(where: { $0.bundleIdentifier == app.id }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    toggleApp(app)
                }
            }

            HStack {
                Text("\(selectedTargets.count)개 선택됨")
                    .foregroundColor(.secondary)
                Spacer()
                Button("완료") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 400, height: 500)
        .onAppear {
            loadInstalledApps()
        }
    }

    private func toggleApp(_ app: InstalledApp) {
        if let index = selectedTargets.firstIndex(where: { $0.bundleIdentifier == app.id }) {
            selectedTargets.remove(at: index)
        } else {
            selectedTargets.append(AppTarget(
                bundleIdentifier: app.id,
                displayName: app.name,
                path: app.path
            ))
        }
    }

    private func loadInstalledApps() {
        var apps: [InstalledApp] = []
        let searchPaths = ["/Applications", "/System/Applications",
                           NSHomeDirectory() + "/Applications"]

        for searchPath in searchPaths {
            guard let contents = try? FileManager.default.contentsOfDirectory(
                atPath: searchPath
            ) else { continue }

            for item in contents where item.hasSuffix(".app") {
                let fullPath = (searchPath as NSString).appendingPathComponent(item)
                guard let bundle = Bundle(path: fullPath),
                      let bundleID = bundle.bundleIdentifier else { continue }

                let name = FileManager.default.displayName(atPath: fullPath)
                    .replacingOccurrences(of: ".app", with: "")
                let icon = NSWorkspace.shared.icon(forFile: fullPath)
                icon.size = NSSize(width: 32, height: 32)

                apps.append(InstalledApp(
                    id: bundleID,
                    name: name,
                    path: fullPath,
                    icon: icon
                ))
            }
        }

        installedApps = apps.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.application]
        panel.allowsMultipleSelection = true
        panel.directoryURL = URL(fileURLWithPath: "/Applications")

        if panel.runModal() == .OK {
            for url in panel.urls {
                guard let bundle = Bundle(url: url),
                      let bundleID = bundle.bundleIdentifier else { continue }
                let name = FileManager.default.displayName(atPath: url.path)
                    .replacingOccurrences(of: ".app", with: "")

                if !selectedTargets.contains(where: { $0.bundleIdentifier == bundleID }) {
                    selectedTargets.append(AppTarget(
                        bundleIdentifier: bundleID,
                        displayName: name,
                        path: url.path
                    ))
                }
            }
        }
    }
}
