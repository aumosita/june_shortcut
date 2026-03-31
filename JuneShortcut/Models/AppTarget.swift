import Foundation

struct AppTarget: Codable, Identifiable, Hashable {
    let id: UUID
    let bundleIdentifier: String
    let displayName: String
    let path: String

    init(id: UUID = UUID(), bundleIdentifier: String, displayName: String, path: String) {
        self.id = id
        self.bundleIdentifier = bundleIdentifier
        self.displayName = displayName
        self.path = path
    }
}
