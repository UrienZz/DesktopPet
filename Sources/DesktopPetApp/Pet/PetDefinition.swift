import Foundation

struct PetDefinition: Codable, Equatable, Sendable {
    let name: String
    let imageSource: String
    let frameSize: Int?
    let width: Int?
    let height: Int?
    let highestFrameMax: Int?
    let totalSpriteLine: Int?
    let states: [String: PetStateDefinition]

    enum CodingKeys: String, CodingKey {
        case name
        case imageSource = "imageSrc"
        case frameSize
        case width
        case height
        case highestFrameMax
        case totalSpriteLine
        case states
    }

    var availableStateNames: [String] {
        states.keys.sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    }

    var preferredStandingStateName: String {
        for candidate in ["stand", "idle", "sit", "greet", "walk", "climb"] {
            if states[candidate] != nil {
                return candidate
            }
        }

        return availableStateNames.first ?? "stand"
    }

    var mediaFileURL: URL {
        AppConstants.mediaDirectoryURL.appendingPathComponent((imageSource as NSString).lastPathComponent)
    }

    func resolvedStateName(for runtimeMode: PetRuntimeMode) -> String {
        switch runtimeMode {
        case .climbLeft, .climbRight:
            return states["climb"] != nil ? "climb" : preferredStandingStateName
        case .bottomIdle:
            return states["sit"] != nil ? "sit" : preferredStandingStateName
        case .dragging:
            return states["drag"] != nil ? "drag" : preferredStandingStateName
        case .standing, .hovering:
            return preferredStandingStateName
        case .falling:
            return states["fall"] != nil ? "fall" : preferredStandingStateName
        }
    }
}

struct PetStateDefinition: Codable, Equatable, Sendable {
    let spriteLine: Int?
    let frameMax: Int?
    let start: Int?
    let end: Int?
}
