import Foundation
import Testing
@testable import DesktopPetApp

/// 验证 framesize 模式可以解析帧尺寸与状态范围。
@Test
func frameSizeModeParsesFrameSizeAndStateRanges() throws {
    let pet = PetDefinition(
        name: "Ayaka",
        imageSource: "media/Ayaka.png",
        frameSize: 128,
        width: nil,
        height: nil,
        highestFrameMax: nil,
        totalSpriteLine: nil,
        states: [
            "climb": PetStateDefinition(spriteLine: 9, frameMax: 8, start: nil, end: nil),
        ]
    )

    let animator = try SpriteSheetAnimator(pet: pet)

    #expect(animator.frameWidth == 128)
    #expect(animator.frameHeight == 128)

    let range = try animator.frameRange(for: "climb")
    #expect(range.lowerBound == 64)
    #expect(range.upperBound == 71)
}

/// 验证 framesize 模式使用全局最大列数而不是当前状态帧数。
@Test
func frameSizeModeUsesGlobalMaxColumnsInsteadOfCurrentStateFrameCount() throws {
    let data = try Data(contentsOf: AppConstants.configDirectoryURL.appendingPathComponent("ayaka.json"))
    let pet = try JSONDecoder().decode(PetDefinition.self, from: data)

    let animator = try SpriteSheetAnimator(pet: pet)

    let standRange = try animator.frameRange(for: "stand")
    let walkRange = try animator.frameRange(for: "walk")
    let climbRange = try animator.frameRange(for: "climb")

    #expect(standRange.lowerBound == 0)
    #expect(walkRange.lowerBound == 8)
    #expect(climbRange.lowerBound == 64)
}

/// 验证裁切坐标从底部开始计算而不是从顶部反转。
@Test
@MainActor
func croppingCoordinatesStartFromBottomInsteadOfTopReversal() {
    let rect = PetRenderView.cropRect(
        frameIndex: 0,
        imageWidth: 1024,
        imageHeight: 1152,
        frameWidth: 128,
        frameHeight: 128
    )

    #expect(rect.origin.x == 0)
    #expect(rect.origin.y == 0)
    #expect(rect.width == 128)
    #expect(rect.height == 128)
}

/// 验证推导尺寸模式可以通过起止帧解析状态范围。
@Test
func inferredSizeModeParsesStateRangesFromStartAndEndFrames() throws {
    let pet = PetDefinition(
        name: "Custom",
        imageSource: "media/custom.png",
        frameSize: nil,
        width: 960,
        height: 512,
        highestFrameMax: 15,
        totalSpriteLine: 8,
        states: [
            "hover": PetStateDefinition(spriteLine: nil, frameMax: nil, start: 3, end: 6),
        ]
    )

    let animator = try SpriteSheetAnimator(pet: pet)

    #expect(animator.frameWidth == 64)
    #expect(animator.frameHeight == 64)

    let range = try animator.frameRange(for: "hover")
    #expect(range.lowerBound == 2)
    #expect(range.upperBound == 5)
}
