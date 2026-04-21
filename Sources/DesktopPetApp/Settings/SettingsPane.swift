import Foundation

enum SettingsPane: String, CaseIterable, Identifiable {
    case pet
    case trello
    case appearance
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pet:
            return "桌宠"
        case .trello:
            return "Trello"
        case .appearance:
            return "外观"
        case .about:
            return "关于"
        }
    }

    var systemImage: String {
        switch self {
        case .pet:
            return "cat.fill"
        case .trello:
            return "rectangle.on.rectangle.circle"
        case .appearance:
            return "paintpalette.fill"
        case .about:
            return "info.circle.fill"
        }
    }
}
