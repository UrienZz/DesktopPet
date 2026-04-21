import CoreGraphics
import Foundation

final class PetRuntimeController {
    let availablePets: [PetDefinition]
    private var pendingLandingPosition: CGPoint?

    private(set) var currentPet: PetDefinition
    private(set) var currentScale: Double
    private(set) var currentMode: PetRuntimeMode
    private(set) var currentPosition: CGPoint

    init(availablePets: [PetDefinition], initialScale: Double, initialPetName: String? = nil) {
        precondition(!availablePets.isEmpty, "availablePets must not be empty")
        self.availablePets = availablePets
        self.currentPet = availablePets.first(where: { $0.name == initialPetName }) ?? availablePets[0]
        self.currentScale = initialScale
        self.currentMode = .climbRight
        self.currentPosition = .zero
    }

    func selectPet(named petName: String) {
        guard let matchedPet = availablePets.first(where: { $0.name == petName }) else {
            return
        }

        currentPet = matchedPet
    }

    func updateScale(_ newScale: Double) {
        currentScale = newScale
    }

    func resetToDefaultPosition(screenFrame: CGRect, petSize: CGSize) {
        currentMode = .climbRight
        pendingLandingPosition = nil
        currentPosition = CGPoint(
            x: screenFrame.maxX - petSize.width - AppConstants.defaultEdgeInset,
            y: screenFrame.minY + (screenFrame.height - petSize.height) / 2
        )
    }

    func moveDraggedPet(to newPosition: CGPoint) {
        currentPosition = newPosition
    }

    func handleDrop(screenFrame: CGRect, petSize: CGSize) {
        let bottomBoundary = screenFrame.minY + AppConstants.snapThreshold
        let leftBoundary = screenFrame.minX + AppConstants.snapThreshold
        let rightBoundary = screenFrame.maxX - petSize.width - AppConstants.snapThreshold
        let topBoundary = screenFrame.maxY - petSize.height - AppConstants.snapThreshold

        let clampedX = min(
            max(currentPosition.x, screenFrame.minX + AppConstants.defaultEdgeInset),
            screenFrame.maxX - petSize.width - AppConstants.defaultEdgeInset
        )

        if currentPosition.y <= bottomBoundary {
            currentMode = .standing
            pendingLandingPosition = nil
            currentPosition = CGPoint(x: clampedX, y: screenFrame.minY + AppConstants.defaultBottomInset)
            return
        }

        if currentPosition.x <= leftBoundary {
            currentMode = .climbLeft
            pendingLandingPosition = nil
            currentPosition = CGPoint(
                x: screenFrame.minX + AppConstants.defaultEdgeInset,
                y: min(max(currentPosition.y, screenFrame.minY), screenFrame.maxY - petSize.height)
            )
            return
        }

        if currentPosition.x >= rightBoundary {
            currentMode = .climbRight
            pendingLandingPosition = nil
            currentPosition = CGPoint(
                x: screenFrame.maxX - petSize.width - AppConstants.defaultEdgeInset,
                y: min(max(currentPosition.y, screenFrame.minY), screenFrame.maxY - petSize.height)
            )
            return
        }

        if currentPosition.y >= topBoundary || currentPosition.y > bottomBoundary {
            currentMode = .falling
            pendingLandingPosition = CGPoint(x: clampedX, y: screenFrame.minY + AppConstants.defaultBottomInset)
        }
    }

    func completeFallIfNeeded() {
        guard currentMode == .falling, let landingPosition = pendingLandingPosition else {
            return
        }

        currentPosition = landingPosition
        currentMode = .standing
        pendingLandingPosition = nil
    }

    func overrideMode(_ mode: PetRuntimeMode) {
        currentMode = mode
    }
}
