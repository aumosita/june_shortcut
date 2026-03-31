import SwiftUI

@main
struct JuneShortcutApp: App {
    @StateObject private var menuBarVM = MenuBarViewModel()
    @StateObject private var shortcutListVM = ShortcutListViewModel()

    var body: some Scene {
        MenuBarExtra("JuneShortcut", systemImage: "command.square") {
            MenuBarView(viewModel: menuBarVM, shortcutListVM: shortcutListVM)
                .onAppear {
                    if shortcutListVM.entries.isEmpty {
                        shortcutListVM.load()
                    }
                    if !HotkeyService.shared.isRunning {
                        HotkeyService.shared.start()
                    }
                }
        }
        .menuBarExtraStyle(.window)

        Window("설정", id: "settings") {
            TabView {
                SettingsView(viewModel: shortcutListVM)
                    .tabItem {
                        Label("단축키", systemImage: "command")
                    }

                GeneralSettingsView()
                    .tabItem {
                        Label("일반", systemImage: "gear")
                    }
            }
            .frame(minWidth: 550, minHeight: 450)
        }
        .defaultSize(width: 600, height: 500)
    }

    init() {
        if !AccessibilityService.isGranted {
            AccessibilityService.requestAccess()
        }
    }
}
