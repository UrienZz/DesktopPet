import Foundation

enum ImportedPetStoreError: Error, Equatable {
    case invalidArchive
    case invalidPetPackage
    case missingJSON
    case missingImage(String)
    case unzipFailed(Int32)
}

struct ImportedPetStore {
    private let baseDirectoryURL: URL
    private let fileManager: FileManager

    init(
        baseDirectoryURL: URL = AppConstants.importedPetsDirectoryURL,
        fileManager: FileManager = .default
    ) {
        self.baseDirectoryURL = baseDirectoryURL
        self.fileManager = fileManager
    }

    func loadImportedPets() throws -> [PetDefinition] {
        guard fileManager.fileExists(atPath: baseDirectoryURL.path) else {
            return []
        }

        let directories = try fileManager.contentsOfDirectory(
            at: baseDirectoryURL,
            includingPropertiesForKeys: nil
        ).filter { url in
            var isDirectory: ObjCBool = false
            fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
            return isDirectory.boolValue
        }

        let decoder = JSONDecoder()
        return try directories
            .sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
            .map { directoryURL in
                let jsonURL = directoryURL.appendingPathComponent("pet.json")
                let data = try Data(contentsOf: jsonURL)
                var pet = try decoder.decode(PetDefinition.self, from: data)
                pet.source = .imported
                pet.resourceBaseURL = directoryURL
                pet.storageDirectoryURL = directoryURL
                return pet
            }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    func importPetArchive(
        from archiveURL: URL,
        reservedNames: Set<String> = []
    ) throws -> PetDefinition {
        guard archiveURL.pathExtension.lowercased() == "zip" else {
            throw ImportedPetStoreError.invalidArchive
        }

        try fileManager.createDirectory(at: baseDirectoryURL, withIntermediateDirectories: true)

        let temporaryDirectoryURL = fileManager.temporaryDirectory
            .appendingPathComponent("DesktopPetImport-\(UUID().uuidString)", isDirectory: true)
        try fileManager.createDirectory(at: temporaryDirectoryURL, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: temporaryDirectoryURL) }

        try unzipArchive(at: archiveURL, into: temporaryDirectoryURL)

        let jsonURL = try locateSingleJSON(in: temporaryDirectoryURL)
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: jsonURL)
        var pet = try decoder.decode(PetDefinition.self, from: data)
        guard !pet.states.isEmpty else {
            throw ImportedPetStoreError.invalidPetPackage
        }

        let existingImportedNames = try Set(loadImportedPets().map(\.name))
        let unavailableNames = reservedNames.union(existingImportedNames)
        pet = renamedPetIfNeeded(pet, unavailableNames: unavailableNames)

        let imageFileName = (pet.imageSource as NSString).lastPathComponent
        guard let imageURL = try locateFile(named: imageFileName, in: temporaryDirectoryURL) else {
            throw ImportedPetStoreError.missingImage(imageFileName)
        }

        let destinationDirectoryURL = baseDirectoryURL.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: destinationDirectoryURL, withIntermediateDirectories: true)
        do {
            let normalizedJSONURL = destinationDirectoryURL.appendingPathComponent("pet.json")
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let normalizedData = try encoder.encode(pet)
            try normalizedData.write(to: normalizedJSONURL)
            try fileManager.copyItem(at: imageURL, to: destinationDirectoryURL.appendingPathComponent(imageFileName))
        } catch {
            try? fileManager.removeItem(at: destinationDirectoryURL)
            throw error
        }

        pet.source = .imported
        pet.resourceBaseURL = destinationDirectoryURL
        pet.storageDirectoryURL = destinationDirectoryURL
        return pet
    }

    func deleteImportedPet(at directoryURL: URL) throws {
        let standardizedBasePath = baseDirectoryURL.standardizedFileURL.path
        let standardizedTargetPath = directoryURL.standardizedFileURL.path
        guard standardizedTargetPath.hasPrefix(standardizedBasePath) else { return }
        if fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.removeItem(at: directoryURL)
        }
    }

    private func unzipArchive(at archiveURL: URL, into destinationURL: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
        process.arguments = ["-x", "-k", archiveURL.path, destinationURL.path]
        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw ImportedPetStoreError.unzipFailed(process.terminationStatus)
        }
    }

    private func locateSingleJSON(in directoryURL: URL) throws -> URL {
        let jsonFiles = try recursiveContents(of: directoryURL)
            .filter { $0.pathExtension.lowercased() == "json" }

        guard let jsonURL = jsonFiles.first else {
            throw ImportedPetStoreError.missingJSON
        }

        return jsonURL
    }

    private func locateFile(named fileName: String, in directoryURL: URL) throws -> URL? {
        try recursiveContents(of: directoryURL)
            .first(where: { $0.lastPathComponent == fileName })
    }

    private func recursiveContents(of directoryURL: URL) throws -> [URL] {
        guard let enumerator = fileManager.enumerator(
            at: directoryURL,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }

        return enumerator.compactMap { $0 as? URL }
    }

    private func renamedPetIfNeeded(
        _ pet: PetDefinition,
        unavailableNames: Set<String>
    ) -> PetDefinition {
        guard unavailableNames.contains(pet.name) else {
            return pet
        }

        var renamedPet = pet
        var suffix = 1
        while unavailableNames.contains("\(pet.name)_\(suffix)") {
            suffix += 1
        }
        renamedPet = PetDefinition(
            name: "\(pet.name)_\(suffix)",
            imageSource: pet.imageSource,
            frameSize: pet.frameSize,
            width: pet.width,
            height: pet.height,
            highestFrameMax: pet.highestFrameMax,
            totalSpriteLine: pet.totalSpriteLine,
            states: pet.states,
            source: pet.source,
            resourceBaseURL: pet.resourceBaseURL,
            storageDirectoryURL: pet.storageDirectoryURL
        )
        return renamedPet
    }
}
