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
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                LabeledContent("当前姿势") {
                    Picker("姿势", selection: Binding(
                        get: { selectedState },
                        set: { onSelectState($0) }
                    )) {
                        ForEach(previewOptions, id: \.id) { option in
                            Text(option.title).tag(option.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 200)
                }

                Text("左爬墙会自动使用右爬墙镜像；预览尺寸会跟随当前缩放同步调整。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                PetPreviewRepresentable(
                    pet: pet,
                    previewState: selectedState,
                    scale: previewRenderScale
                )
                .frame(width: previewContentSize.width, height: previewContentSize.height)
            }
            .frame(width: PosePreviewLayout.cardDimension, height: PosePreviewLayout.cardDimension)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(nsColor: .underPageBackgroundColor))
            )
        }
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
