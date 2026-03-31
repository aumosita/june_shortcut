import Foundation

@MainActor
final class MenuBarViewModel: ObservableObject {
    @Published var isGlobalEnabled = true

    private let hotkeyService = HotkeyService.shared

    func toggleGlobal() {
        isGlobalEnabled.toggle()
        if isGlobalEnabled {
            hotkeyService.start()
        } else {
            hotkeyService.stop()
        }
    }
}
