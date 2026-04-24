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
