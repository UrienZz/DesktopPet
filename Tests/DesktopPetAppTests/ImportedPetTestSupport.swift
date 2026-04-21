import Foundation

struct ImportedPetWorkspace {
    let rootURL: URL
    let importedPetsURL: URL
    let sourceArchiveRootURL: URL
}

func makeWorkspace(named name: String) throws -> ImportedPetWorkspace {
    let rootURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("ImportedPetStoreTests-\(name)-\(UUID().uuidString)")
    let importedPetsURL = rootURL.appendingPathComponent("ImportedPets", isDirectory: true)
    let sourceArchiveRootURL = rootURL.appendingPathComponent("Archives", isDirectory: true)

    try FileManager.default.createDirectory(at: importedPetsURL, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: sourceArchiveRootURL, withIntermediateDirectories: true)

    return ImportedPetWorkspace(
        rootURL: rootURL,
        importedPetsURL: importedPetsURL,
        sourceArchiveRootURL: sourceArchiveRootURL
    )
}

func makePetArchive(
    workspace: ImportedPetWorkspace,
    petName: String,
    imageSource: String,
    includePNG: Bool
) throws -> URL {
    let payloadURL = workspace.sourceArchiveRootURL.appendingPathComponent(UUID().uuidString, isDirectory: true)
    try FileManager.default.createDirectory(at: payloadURL, withIntermediateDirectories: true)

    let jsonURL = payloadURL.appendingPathComponent("pet.json")
    let imageURL = payloadURL.appendingPathComponent((imageSource as NSString).lastPathComponent)

    let json = """
    {
      "name": "\(petName)",
      "imageSrc": "\(imageSource)",
      "frameSize": 128,
      "states": {
        "stand": {
          "spriteLine": 1,
          "frameMax": 1
        }
      }
    }
    """
    try json.write(to: jsonURL, atomically: true, encoding: .utf8)

    if includePNG {
        try Data([0x89, 0x50, 0x4E, 0x47]).write(to: imageURL)
    }

    let archiveURL = workspace.sourceArchiveRootURL.appendingPathComponent("\(UUID().uuidString).zip")
    try zipDirectory(at: payloadURL, to: archiveURL)
    return archiveURL
}

func zipDirectory(at sourceURL: URL, to archiveURL: URL) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
    process.arguments = ["-c", "-k", "--sequesterRsrc", "--keepParent", sourceURL.path, archiveURL.path]
    try process.run()
    process.waitUntilExit()

    guard process.terminationStatus == 0 else {
        throw NSError(domain: "ImportedPetStoreTests", code: Int(process.terminationStatus))
    }
}
