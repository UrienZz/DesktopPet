import SwiftUI

struct SizeControlView: View {
    let scale: Double
    let onChangeScale: (Double) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("缩放比例")
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Text("\(Int((scale * 100).rounded()))%")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }

            Slider(
                value: Binding(
                    get: { scale },
                    set: { onChangeScale($0) }
                ),
                in: 0.3...1.4
            )

            HStack {
                Text("30%")
                Spacer()
                Text("140%")
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.secondary)
        }
    }
}
