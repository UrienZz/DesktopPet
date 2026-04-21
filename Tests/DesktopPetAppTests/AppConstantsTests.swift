import Foundation
import Testing
@testable import DesktopPetApp

@Test
func 资源目录与Trello地址已配置() throws {
    #expect(!AppConstants.trelloBoardURL.absoluteString.isEmpty)
    #expect(FileManager.default.fileExists(atPath: AppConstants.configDirectoryURL.path))
    #expect(FileManager.default.fileExists(atPath: AppConstants.mediaDirectoryURL.path))
}
