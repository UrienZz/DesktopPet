import Foundation
import Testing
@testable import DesktopPetApp

/// 验证合法宠物包可以成功导入并被列出。
@Test
func validPetArchiveImportsAndListsSuccessfully() throws {
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

/// 验证缺少图片资源时导入失败且不会写入目录。
@Test
func missingImageResourceFailsImportWithoutWritingDirectory() throws {
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

/// 验证删除导入宠物后会清理存储目录。
@Test
func deletingImportedPetCleansStorageDirectory() throws {
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

/// 验证与内置宠物重名时会自动追加递增后缀。
@Test
func duplicateBundledPetNameAppendsIncrementingSuffix() throws {
    let workspace = try makeWorkspace(named: "rename-bundled-duplicate")
    let store = ImportedPetStore(baseDirectoryURL: workspace.importedPetsURL)
    let archiveURL = try makePetArchive(
        workspace: workspace,
        petName: "Spongebob",
        imageSource: "media/spongebob-copy.png",
        includePNG: true
    )

    let importedPet = try store.importPetArchive(from: archiveURL, reservedNames: ["Spongebob"])
    let loadedPets = try store.loadImportedPets()

    #expect(importedPet.name == "Spongebob_1")
    #expect(loadedPets.map(\.name) == ["Spongebob_1"])
}

/// 验证多次导入同名宠物时后缀会持续递增。
@Test
func repeatedDuplicateImportsContinueIncrementingSuffix() throws {
    let workspace = try makeWorkspace(named: "rename-imported-duplicate")
    let store = ImportedPetStore(baseDirectoryURL: workspace.importedPetsURL)
    let firstArchiveURL = try makePetArchive(
        workspace: workspace,
        petName: "Batman",
        imageSource: "media/batman-copy-1.png",
        includePNG: true
    )
    let secondArchiveURL = try makePetArchive(
        workspace: workspace,
        petName: "Batman",
        imageSource: "media/batman-copy-2.png",
        includePNG: true
    )

    let firstImportedPet = try store.importPetArchive(from: firstArchiveURL, reservedNames: ["Batman"])
    let secondImportedPet = try store.importPetArchive(from: secondArchiveURL, reservedNames: ["Batman"])
    let loadedPets = try store.loadImportedPets()

    #expect(firstImportedPet.name == "Batman_1")
    #expect(secondImportedPet.name == "Batman_2")
    #expect(loadedPets.map(\.name) == ["Batman_1", "Batman_2"])
}
