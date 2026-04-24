import Foundation
import Testing
@testable import DesktopPetApp

/// 验证多帧姿势默认会开启逐帧动画。
@MainActor
@Test
func multiFramePoseStartsFrameAnimationByDefault() throws {
    let pet = try loadAyaka()
    let renderView = PetRenderView(
        pet: pet,
        runtimeMode: .climbRight,
        scaleFactor: 0.7
    )

    #expect(renderView.isFrameAnimationActiveForTesting)
}

/// 验证暂停后会停止逐帧动画，恢复后继续播放。
@MainActor
@Test
func pausingStopsFrameAnimationAndResumingContinues() throws {
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
