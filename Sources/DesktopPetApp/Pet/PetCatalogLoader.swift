import Foundation

struct PetCatalogLoader {
    func loadAllPets() throws -> [PetDefinition] {
        let directoryContents = try FileManager.default.contentsOfDirectory(
            at: AppConstants.configDirectoryURL,
            includingPropertiesForKeys: nil
        )

        let petFiles = directoryContents
            .filter { $0.pathExtension.lowercased() == "json" }
            .sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }

        let decoder = JSONDecoder()

        return try petFiles
            .map { fileURL in
                let data = try Data(contentsOf: fileURL)
                return try decoder.decode(PetDefinition.self, from: data)
            }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
