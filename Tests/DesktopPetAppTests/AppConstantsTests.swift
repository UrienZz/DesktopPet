import Foundation
import Testing
@testable import DesktopPetApp

/// 验证资源目录和默认插件地址常量已完成配置。
@Test
func resourcesDirectoryAndDefaultPluginURLAreConfigured() throws {
    #expect(!AppConstants.defaultPluginURL.absoluteString.isEmpty)
    #expect(FileManager.default.fileExists(atPath: AppConstants.configDirectoryURL.path))
    #expect(FileManager.default.fileExists(atPath: AppConstants.mediaDirectoryURL.path))
}

/// 验证设置窗口使用更紧凑的系统设置式默认尺寸。
@Test
func settingsWindowUsesCompactDefaultSize() {
    #expect(AppConstants.settingsWindowSize.width == 900)
    #expect(AppConstants.settingsWindowSize.height == 640)
}
