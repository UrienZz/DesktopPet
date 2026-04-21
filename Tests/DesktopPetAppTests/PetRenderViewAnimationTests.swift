import Foundation
import Testing
@testable import DesktopPetApp

@MainActor
@Test
func 多帧姿势默认应开启逐帧动画() throws {
    let pet = try loadAyaka()
    let renderView = PetRenderView(
        pet: pet,
        runtimeMode: .climbRight,
        scaleFactor: 0.7
    )

    #expect(renderView.isFrameAnimationActiveForTesting)
}

@MainActor
@Test
func 暂停后应停止逐帧动画恢复后继续() throws {
    let pet = try loadAyaka()
    let renderView = PetRenderView(
        pet: pet,
        runtimeMode: .climbRight,
        scaleFactor: 0.7
    )

    renderView.isAnimationPaused = true
    #expect(renderView.isFrameAnimationActiveForTesting == false)

    renderView.isAnimationPaused = false
    #expect(renderView.isFrameAnimationActiveForTesting)
}

private func loadAyaka() throws -> PetDefinition {
    let data = try Data(contentsOf: AppConstants.configDirectoryURL.appendingPathComponent("ayaka.json"))
    return try JSONDecoder().decode(PetDefinition.self, from: data)
}
