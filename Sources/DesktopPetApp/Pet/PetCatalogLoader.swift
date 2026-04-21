import Foundation

struct PetCatalogLoader {
    private let bundledConfigDirectoryURL: URL
    private let importedPetStore: ImportedPetStore

    init(
        bundledConfigDirectoryURL: URL = AppConstants.configDirectoryURL,
        importedPetStore: ImportedPetStore = ImportedPetStore()
    ) {
        self.bundledConfigDirectoryURL = bundledConfigDirectoryURL
        self.importedPetStore = importedPetStore
    }

    func loadAllPets() throws -> [PetDefinition] {
        let directoryContents = try FileManager.default.contentsOfDirectory(
            at: bundledConfigDirectoryURL,
            includingPropertiesForKeys: nil
        )

        let petFiles = directoryContents
            .filter { $0.pathExtension.lowercased() == "json" }
            .sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }

        let decoder = JSONDecoder()

        let bundledPets = try petFiles
            .map { fileURL in
                let data = try Data(contentsOf: fileURL)
                var pet = try decoder.decode(PetDefinition.self, from: data)
                pet.source = .bundled
                pet.resourceBaseURL = nil
                pet.storageDirectoryURL = nil
                return pet
            }
        let importedPets = try importedPetStore.loadImportedPets()

        return (bundledPets + importedPets)
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
