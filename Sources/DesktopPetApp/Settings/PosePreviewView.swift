import SwiftUI

struct PosePreviewView: View {
    let pet: PetDefinition
    let selectedState: String
    let scale: Double
    let onSelectState: (String) -> Void

    private var previewStates: [String] {
        let base = pet.availableStateNames
        if base.contains("climb"), !base.contains("climbLeft") {
            return ["climbLeft"] + base
        }
        return base
    }

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                LabeledContent("当前姿势") {
                    Picker("姿势", selection: Binding(
                        get: { selectedState },
                        set: { onSelectState($0) }
                    )) {
                        ForEach(previewStates, id: \.self) { state in
                            Text(state).tag(state)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 200)
                }

                Text("左爬墙会自动使用右爬墙镜像；预览区域独立于桌面宠物运行态。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            PetPreviewRepresentable(
                pet: pet,
                previewState: selectedState,
                scale: CGFloat(scale)
            )
            .frame(width: 240, height: 240)
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
        let renderView = PetRenderView(
            pet: pet,
            runtimeMode: runtimeMode(for: previewState),
            scaleFactor: scale
        )
        renderView.interactionEnabled = false
        return renderView
    }

    func updateNSView(_ nsView: PetRenderView, context: Context) {
        nsView.pet = pet
        nsView.scaleFactor = scale
        nsView.runtimeMode = runtimeMode(for: previewState)
    }

    private func runtimeMode(for state: String) -> PetRuntimeMode {
        switch state {
        case "climbLeft":
            return .climbLeft
        case "climb":
            return .climbRight
        case "fall":
            return .falling
        default:
            return .standing
        }
    }
}
