import Foundation

struct PluginConfiguration: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    var name: String
    var url: URL
    var iconName: String
    var isEnabled: Bool
    var sortOrder: Int
}
