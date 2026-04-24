import Foundation
import Testing
@testable import DesktopPetApp

/// 验证拖拽开始且存在 drag 素材时会切换到 dragging。
@MainActor
@Test
func dragStartWithDragAssetSwitchesToDragging() throws {
    let pet = try loadAyaka()

    #expect(PetRenderView.dragRuntimeMode(for: pet, currentMode: .climbRight) == .dragging)
}

/// 验证拖拽开始但没有 drag 素材时保持当前动作。
@MainActor
@Test
func dragStartWithoutDragAssetKeepsCurrentPose() {
    let pet = PetDefinition(
        name: "Custom",
        imageSource: "media/custom.png",
        frameSize: 128,
        width: nil,
        height: nil,
        highestFrameMax: nil,
        totalSpriteLine: nil,
        states: [
            "stand": PetStateDefinition(spriteLine: 1, frameMax: 1, start: nil, end: nil),
        ]
    )

    #expect(PetRenderView.dragRuntimeMode(for: pet, currentMode: .climbLeft) == .climbLeft)
}

private func loadAyaka() throws -> PetDefinition {
    let data = try Data(contentsOf: AppConstants.configDirectoryURL.appendingPathComponent("ayaka.json"))
    return try JSONDecoder().decode(PetDefinition.self, from: data)
}
