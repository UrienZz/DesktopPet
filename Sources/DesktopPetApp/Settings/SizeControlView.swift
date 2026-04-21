import SwiftUI

struct SizeControlView: View {
    let scale: Double
    let onChangeScale: (Double) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            LabeledContent("缩放比例") {
                Text(scale.formatted(.number.precision(.fractionLength(2))))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }

            Slider(
                value: Binding(
                    get: { scale },
                    set: { onChangeScale($0) }
                ),
                in: 0.3...1.4
            )

            Text("调整后会即时同步到桌面宠物与预览区域。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
