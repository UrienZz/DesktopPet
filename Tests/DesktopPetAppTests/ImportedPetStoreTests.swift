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

@Test
func 与内置宠物重名时应自动追加递增后缀() throws {
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

@Test
func 多次导入同名宠物时应持续递增后缀() throws {
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
