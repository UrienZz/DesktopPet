import SwiftUI

struct SettingsActionsView: View {
    let onOpenPluginPanel: () -> Void
    let onResetPosition: () -> Void
    let onQuit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button("打开插件面板", action: onOpenPluginPanel)
                    .buttonStyle(.borderedProminent)
                Button("重置宠物位置", action: onResetPosition)
                    .buttonStyle(.bordered)
                Button("退出", role: .destructive, action: onQuit)
                    .buttonStyle(.bordered)
            }
        }
    }
}
