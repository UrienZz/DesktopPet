import CoreGraphics
import Foundation

struct PosePreviewOption: Equatable, Sendable {
    let id: String
    let title: String
}

struct PosePreviewRenderConfiguration: Equatable, Sendable {
    let stateName: String
    let isMirrored: Bool
}

enum PosePreviewCatalog {
    static func options(for pet: PetDefinition) -> [PosePreviewOption] {
        let baseOptions = pet.availableStateNames.map { stateName in
            PosePreviewOption(id: stateName, title: displayTitle(for: stateName))
        }

        guard pet.states["climb"] != nil, pet.states["climbLeft"] == nil else {
            return baseOptions
        }

        return [PosePreviewOption(id: "climbLeft", title: displayTitle(for: "climbLeft"))] + baseOptions
    }

    static func displayTitle(for stateName: String) -> String {
        switch stateName {
        case "climbLeft":
            return "左侧爬墙"
        case "climb":
            return "右侧爬墙"
        case "crawl":
            return "匍匐"
        case "drag":
            return "被拖拽"
        case "fall":
            return "下落"
        case "greet":
            return "打招呼"
        case "hover":
            return "悬停"
        case "idle":
            return "待机"
        case "jump":
            return "跳跃"
        case "sit":
            return "坐下"
        case "stand":
            return "站立"
        case "walk":
            return "行走"
        default:
            return "姿势：\(stateName)"
        }
    }

    static func renderConfiguration(for stateName: String) -> PosePreviewRenderConfiguration {
        if stateName == "climbLeft" {
            return PosePreviewRenderConfiguration(stateName: "climb", isMirrored: true)
        }

        return PosePreviewRenderConfiguration(stateName: stateName, isMirrored: false)
    }
}

enum PosePreviewLayout {
    static let cardDimension: CGFloat = 240
    static let contentMaxDimension: CGFloat = 208
    static let minCardDimension: CGFloat = 160
    static let compactControlsWidth: CGFloat = 360
    static let pickerMinimumWidth: CGFloat = 170

    static func renderScale(
        for pet: PetDefinition,
        selectedScale: Double,
        maxDimension: CGFloat = contentMaxDimension
    ) throws -> CGFloat {
        let animator = try SpriteSheetAnimator(pet: pet)
        let requestedScale = max(CGFloat(selectedScale), 0.1)
        let scaledWidth = CGFloat(animator.frameWidth) * requestedScale
        let scaledHeight = CGFloat(animator.frameHeight) * requestedScale
        let fitScale = min(1, maxDimension / max(scaledWidth, scaledHeight))
        return requestedScale * fitScale
    }

    static func contentSize(
        for pet: PetDefinition,
        selectedScale: Double,
        maxDimension: CGFloat = contentMaxDimension
    ) throws -> CGSize {
        let animator = try SpriteSheetAnimator(pet: pet)
        let resolvedScale = try renderScale(for: pet, selectedScale: selectedScale, maxDimension: maxDimension)

        return CGSize(
            width: CGFloat(animator.frameWidth) * resolvedScale,
            height: CGFloat(animator.frameHeight) * resolvedScale
        )
    }

    static func fittedCardDimension(availableWidth: CGFloat, availableHeight: CGFloat) -> CGFloat {
        let availableDimension = min(availableWidth, availableHeight)
        return max(minCardDimension, min(cardDimension, availableDimension))
    }

    static func contentMaxDimension(for cardDimension: CGFloat) -> CGFloat {
        max(96, cardDimension - 32)
    }
}
