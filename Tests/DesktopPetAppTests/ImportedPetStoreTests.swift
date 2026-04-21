import Foundation
import Testing
@testable import DesktopPetApp

@Test
func 合法宠物包可成功导入并列出() throws {
    let workspace = try makeWorkspace(named: "valid")
    let store = ImportedPetStore(baseDirectoryURL: workspace.importedPetsURL)
    let archiveURL = try makePetArchive(
        workspace: workspace,
        petName: "Custom Ayaka",
        imageSource: "media/custom-ayaka.png",
        includePNG: true
    )

    let importedPet = try store.importPetArchive(from: archiveURL)
    let loadedPets = try store.loadImportedPets()

    #expect(importedPet.name == "Custom Ayaka")
    #expect(importedPet.isImported)
    #expect(importedPet.storageDirectoryURL != nil)
    #expect(loadedPets.count == 1)
    #expect(loadedPets.first?.name == "Custom Ayaka")
    #expect(loadedPets.first?.mediaFileURL.lastPathComponent == "custom-ayaka.png")
}

@Test
func 缺少图片资源时导入失败且不写入目录() throws {
    let workspace = try makeWorkspace(named: "missing-image")
    let store = ImportedPetStore(baseDirectoryURL: workspace.importedPetsURL)
    let archiveURL = try makePetArchive(
        workspace: workspace,
        petName: "Broken Pet",
        imageSource: "media/broken.png",
        includePNG: false
    )

    #expect(throws: ImportedPetStoreError.self) {
        try store.importPetArchive(from: archiveURL)
    }
    #expect(try store.loadImportedPets().isEmpty)
}

@Test
func 删除导入宠物后应清理目录() throws {
    let workspace = try makeWorkspace(named: "delete")
    let store = ImportedPetStore(baseDirectoryURL: workspace.importedPetsURL)
    let archiveURL = try makePetArchive(
        workspace: workspace,
        petName: "Delete Me",
        imageSource: "media/delete-me.png",
        includePNG: true
    )

    let importedPet = try store.importPetArchive(from: archiveURL)
    let storageURL = try #require(importedPet.storageDirectoryURL)

    try store.deleteImportedPet(at: storageURL)

    #expect(!FileManager.default.fileExists(atPath: storageURL.path))
    #expect(try store.loadImportedPets().isEmpty)
}
