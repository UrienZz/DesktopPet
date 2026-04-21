import Foundation

enum SpriteSheetAnimatorError: Error {
    case invalidFrameMetrics
    case missingState(String)
    case invalidStateRange(String)
}

struct SpriteSheetAnimator {
    let pet: PetDefinition
    let frameWidth: Int
    let frameHeight: Int

    init(pet: PetDefinition) throws {
        self.pet = pet

        if let frameSize = pet.frameSize {
            frameWidth = frameSize
            frameHeight = frameSize
            return
        }

        guard
            let width = pet.width,
            let height = pet.height,
            let highestFrameMax = pet.highestFrameMax,
            let totalSpriteLine = pet.totalSpriteLine,
            highestFrameMax > 0,
            totalSpriteLine > 0
        else {
            throw SpriteSheetAnimatorError.invalidFrameMetrics
        }

        frameWidth = width / highestFrameMax
        frameHeight = height / totalSpriteLine
    }

    func frameRange(for stateName: String) throws -> ClosedRange<Int> {
        guard let state = pet.states[stateName] else {
            throw SpriteSheetAnimatorError.missingState(stateName)
        }

        if let start = state.start, let end = state.end, start > 0, end >= start {
            return (start - 1)...(end - 1)
        }

        guard
            let spriteLine = state.spriteLine,
            let frameMax = state.frameMax,
            frameMax > 0
        else {
            throw SpriteSheetAnimatorError.invalidStateRange(stateName)
        }

        let maxFramesPerLine = pet.highestFrameMax
            ?? pet.states.values.compactMap(\.frameMax).max()
            ?? frameMax
        let lowerBound = (spriteLine - 1) * maxFramesPerLine
        let upperBound = lowerBound + frameMax - 1
        return lowerBound...upperBound
    }
}
