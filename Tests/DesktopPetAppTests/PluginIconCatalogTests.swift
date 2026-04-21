import Testing
@testable import DesktopPetApp

@Test
func 默认图标应映射到预设选项() {
    #expect(PluginIconCatalog.selectionID(for: AppConstants.defaultPluginIconName) == AppConstants.defaultPluginIconName)
}

@Test
func 未知图标应映射到自定义选项() {
    #expect(PluginIconCatalog.selectionID(for: "paperplane.circle.badge.clock") == PluginIconCatalog.customOptionID)
}

@Test
func 自定义选项应返回裁剪后的图标名称() {
    let resolved = PluginIconCatalog.resolvedIconName(
        selectionID: PluginIconCatalog.customOptionID,
        customIconName: "  globe.badge.chevron.backward  "
    )

    #expect(resolved == "globe.badge.chevron.backward")
}
