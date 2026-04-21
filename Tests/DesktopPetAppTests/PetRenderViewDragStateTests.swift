import Foundation
import Testing
@testable import DesktopPetApp

@MainActor
@Test
func 拖拽开始时有drag素材应切换到dragging() throws {
    let pet = try loadAyaka()

    #expect(PetRenderView.dragRuntimeMode(for: pet, currentMode: .climbRight) == .dragging)
}

@MainActor
@Test
func 拖拽开始时无drag素材应保持当前动作() {
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
