import Cocoa

final class AppLaunchService {
    static let shared = AppLaunchService()

    private init() {}

    func launch(targets: [AppTarget]) {
        for target in targets {
            guard let url = NSWorkspace.shared.urlForApplication(
                withBundleIdentifier: target.bundleIdentifier
            ) else { continue }

            let config = NSWorkspace.OpenConfiguration()
            config.activates = true
            NSWorkspace.shared.openApplication(at: url, configuration: config)
        }
    }
}
