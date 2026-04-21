import Foundation

enum SettingsPane: String, CaseIterable, Identifiable {
    case pet
    case plugins
    case appearance
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pet:
            return "桌宠"
        case .plugins:
            return "插件"
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
        case .plugins:
            return "puzzlepiece.extension"
        case .appearance:
            return "paintpalette.fill"
        case .about:
            return "info.circle.fill"
        }
    }
}
