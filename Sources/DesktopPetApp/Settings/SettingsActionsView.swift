import SwiftUI

struct SettingsActionsView: View {
    let onOpenTrello: () -> Void
    let onResetPosition: () -> Void
    let onQuit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button("打开 Trello", action: onOpenTrello)
                    .buttonStyle(.borderedProminent)
                Button("重置宠物位置", action: onResetPosition)
                    .buttonStyle(.bordered)
                Button("退出", role: .destructive, action: onQuit)
                    .buttonStyle(.bordered)
            }
        }
    }
}
