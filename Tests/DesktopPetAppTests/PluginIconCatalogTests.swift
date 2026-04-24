import Testing
@testable import DesktopPetApp

/// 验证默认图标会映射到预设图标选项。
@Test
func defaultIconMapsToPresetOption() {
    #expect(PluginIconCatalog.selectionID(for: AppConstants.defaultPluginIconName) == AppConstants.defaultPluginIconName)
}

/// 验证未知图标会映射到自定义图标选项。
@Test
func unknownIconMapsToCustomOption() {
    #expect(PluginIconCatalog.selectionID(for: "paperplane.circle.badge.clock") == PluginIconCatalog.customOptionID)
}

/// 验证自定义图标选项会返回裁剪后的图标名称。
@Test
func customOptionReturnsTrimmedIconName() {
    let resolved = PluginIconCatalog.resolvedIconName(
        selectionID: PluginIconCatalog.customOptionID,
        customIconName: "  globe.badge.chevron.backward  "
    )

    #expect(resolved == "globe.badge.chevron.backward")
}
