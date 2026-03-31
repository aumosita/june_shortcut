import Foundation
import ServiceManagement

final class LoginItemService: ObservableObject {
    static let shared = LoginItemService()

    @Published var isEnabled: Bool {
        didSet {
            guard oldValue != isEnabled else { return }
            toggle(isEnabled)
        }
    }

    private init() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    private func toggle(_ enable: Bool) {
        do {
            if enable {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            isEnabled = SMAppService.mainApp.status == .enabled
        }
    }
}
