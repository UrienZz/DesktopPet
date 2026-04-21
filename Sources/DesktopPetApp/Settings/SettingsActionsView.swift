import SwiftUI

struct SettingsActionsView: View {
    let onOpenPluginPanel: () -> Void
    let onResetPosition: () -> Void
    let onQuit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Button("打开插件面板", action: onOpenPluginPanel)
                    .buttonStyle(SettingsActionButtonStyle(tint: .accentColor))
                Button("重置宠物位置", action: onResetPosition)
                    .buttonStyle(SettingsActionButtonStyle(tint: .accentColor, isFilled: false))
                Button("退出", role: .destructive, action: onQuit)
                    .buttonStyle(SettingsActionButtonStyle(tint: .red))
            }

            Text("这些操作会直接影响当前桌面上的桌宠状态。")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
}
