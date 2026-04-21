import Foundation

struct PluginIconOption: Identifiable, Equatable {
    let id: String
    let title: String
    let iconName: String
}

enum PluginIconCatalog {
    static let customOptionID = "__custom__"

    static let options: [PluginIconOption] = [
        PluginIconOption(id: "tray.fill", title: "收纳托盘", iconName: "tray.fill"),
        PluginIconOption(id: "puzzlepiece.extension", title: "插件扩展", iconName: "puzzlepiece.extension"),
        PluginIconOption(id: "rectangle.grid.2x2.fill", title: "网格面板", iconName: "rectangle.grid.2x2.fill"),
        PluginIconOption(id: "doc.text.fill", title: "文档内容", iconName: "doc.text.fill"),
        PluginIconOption(id: "globe", title: "网页站点", iconName: "globe"),
        PluginIconOption(id: "link", title: "链接跳转", iconName: "link"),
        PluginIconOption(id: "bookmark.fill", title: "书签收藏", iconName: "bookmark.fill"),
        PluginIconOption(id: "list.bullet.rectangle.fill", title: "列表视图", iconName: "list.bullet.rectangle.fill"),
        PluginIconOption(id: "checklist", title: "任务清单", iconName: "checklist"),
        PluginIconOption(id: "calendar", title: "日程计划", iconName: "calendar"),
        PluginIconOption(id: customOptionID, title: "自定义图标", iconName: "slider.horizontal.3"),
    ]

    static func selectionID(for iconName: String) -> String {
        let trimmed = iconName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard options.contains(where: { $0.id == trimmed && $0.id != customOptionID }) else {
            return customOptionID
        }

        return trimmed
    }

    static func resolvedIconName(selectionID: String, customIconName: String) -> String {
        let trimmedCustomIconName = customIconName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard selectionID == customOptionID else {
            return selectionID
        }

        return trimmedCustomIconName
    }

    static func option(for selectionID: String) -> PluginIconOption? {
        options.first(where: { $0.id == selectionID })
    }

    static func displayIconName(selectionID: String, customIconName: String) -> String {
        let resolved = resolvedIconName(selectionID: selectionID, customIconName: customIconName)
        return resolved.isEmpty ? AppConstants.defaultPluginIconName : resolved
    }
}
