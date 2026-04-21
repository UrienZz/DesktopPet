import SwiftUI

struct PosePreviewView: View {
    let pet: PetDefinition
    let selectedState: String
    let scale: Double
    let onSelectState: (String) -> Void

    private var previewOptions: [PosePreviewOption] {
        PosePreviewCatalog.options(for: pet)
    }

    private var previewContentSize: CGSize {
        (try? PosePreviewLayout.contentSize(for: pet, selectedScale: scale))
            ?? CGSize(width: 96, height: 96)
    }

    private var previewRenderScale: CGFloat {
        (try? PosePreviewLayout.renderScale(for: pet, selectedScale: scale))
            ?? CGFloat(scale)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 14) {
                    SettingsInfoPill(label: "当前姿势", value: currentPoseTitle)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("姿势选择")
                            .font(.system(size: 13, weight: .semibold))
                        Picker("姿势", selection: Binding(
                            get: { selectedState },
                            set: { onSelectState($0) }
                        )) {
                            ForEach(previewOptions, id: \.id) { option in
                                Text(option.title).tag(option.id)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Text("左爬墙会自动使用右爬墙镜像；预览尺寸会跟随当前缩放同步调整。")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            previewCard
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var currentPoseTitle: String {
        previewOptions.first(where: { $0.id == selectedState })?.title ?? "未选择"
    }

    private var previewCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(nsColor: .underPageBackgroundColor),
                            Color.white.opacity(0.92),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.76), lineWidth: 1)

            PetPreviewRepresentable(
                pet: pet,
                previewState: selectedState,
                scale: previewRenderScale
            )
            .frame(width: previewContentSize.width, height: previewContentSize.height)
        }
        .frame(width: PosePreviewLayout.cardDimension, height: PosePreviewLayout.cardDimension)
        .shadow(color: .black.opacity(0.06), radius: 18, y: 10)
    }
}

private struct PetPreviewRepresentable: NSViewRepresentable {
    let pet: PetDefinition
    let previewState: String
    let scale: CGFloat

    func makeNSView(context: Context) -> PetRenderView {
        let configuration = PosePreviewCatalog.renderConfiguration(for: previewState)
        let renderView = PetRenderView(
            pet: pet,
            runtimeMode: .standing,
            scaleFactor: scale
        )
        renderView.interactionEnabled = false
        renderView.forcedStateName = configuration.stateName
        renderView.forceMirrored = configuration.isMirrored
        return renderView
    }

    func updateNSView(_ nsView: PetRenderView, context: Context) {
        let configuration = PosePreviewCatalog.renderConfiguration(for: previewState)
        nsView.pet = pet
        nsView.scaleFactor = scale
        nsView.runtimeMode = .standing
        nsView.forcedStateName = configuration.stateName
        nsView.forceMirrored = configuration.isMirrored
    }
}
