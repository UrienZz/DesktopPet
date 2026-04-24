import CoreGraphics
import Foundation
import Testing
@testable import DesktopPetApp

/// 验证姿势预览包含全部真实姿势并追加左爬墙镜像选项。
@Test
func posePreviewIncludesAllRealPosesAndAddsLeftClimbMirrorOption() throws {
    let data = try Data(contentsOf: AppConstants.configDirectoryURL.appendingPathComponent("ayaka.json"))
    let pet = try JSONDecoder().decode(PetDefinition.self, from: data)

    let options = PosePreviewCatalog.options(for: pet)

    #expect(options.map(\.id) == ["climbLeft", "climb", "crawl", "drag", "fall", "greet", "jump", "sit", "stand", "walk"])
}

/// 验证姿势预览优先显示中文名称。
@Test
func posePreviewPrefersLocalizedChineseName() throws {
    let data = try Data(contentsOf: AppConstants.configDirectoryURL.appendingPathComponent("ayaka.json"))
    let pet = try JSONDecoder().decode(PetDefinition.self, from: data)

    let options = PosePreviewCatalog.options(for: pet)

    #expect(options.first(where: { $0.id == "climbLeft" })?.title == "左侧爬墙")
    #expect(options.first(where: { $0.id == "climb" })?.title == "右侧爬墙")
    #expect(options.first(where: { $0.id == "crawl" })?.title == "匍匐")
    #expect(options.first(where: { $0.id == "stand" })?.title == "站立")
}

/// 验证左爬墙预览映射到右爬墙素材并启用镜像。
@Test
func leftClimbPreviewMapsToRightClimbAssetAndEnablesMirroring() {
    let configuration = PosePreviewCatalog.renderConfiguration(for: "climbLeft")

    #expect(configuration.stateName == "climb")
    #expect(configuration.isMirrored)
}

/// 验证姿势预览尺寸跟随当前缩放并限制最大显示尺寸。
@Test
func posePreviewSizeFollowsCurrentScaleAndCapsMaximumDisplaySize() throws {
    let data = try Data(contentsOf: AppConstants.configDirectoryURL.appendingPathComponent("ayaka.json"))
    let pet = try JSONDecoder().decode(PetDefinition.self, from: data)

    let small = try PosePreviewLayout.contentSize(for: pet, selectedScale: 0.5)
    let medium = try PosePreviewLayout.contentSize(for: pet, selectedScale: 0.9)
    let large = try PosePreviewLayout.contentSize(for: pet, selectedScale: 3.0)

    #expect(small == CGSize(width: 64, height: 64))
    #expect(medium == CGSize(width: 115.2, height: 115.2))
    #expect(large == CGSize(width: 208, height: 208))
}

/// 验证姿势预览画布尺寸受可用空间约束。
@Test
func posePreviewCanvasSizeIsConstrainedByAvailableSpace() {
    let compact = PosePreviewLayout.fittedCardDimension(availableWidth: 280, availableHeight: 188)
    let roomy = PosePreviewLayout.fittedCardDimension(availableWidth: 420, availableHeight: 360)

    #expect(compact == 188)
    #expect(roomy == PosePreviewLayout.cardDimension)
}
