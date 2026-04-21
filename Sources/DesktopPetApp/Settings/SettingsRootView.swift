import SwiftUI

struct SettingsRootView: View {
    @ObservedObject var coordinator: AppCoordinator
    @State private var selectedPane: SettingsPane = .pet

    var body: some View {
        ZStack {
            SettingsPageBackground()

            HStack(spacing: 0) {
                sidebar

                detailView(for: selectedPane)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.clear)
            }
        }
        .frame(minWidth: 1040, minHeight: 760)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Desktop Pet")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Text("设置")
                    .font(.system(size: 28, weight: .bold))
                Text("桌宠、插件与窗口体验都在这里调整。")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.7))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.72), lineWidth: 1)
            )

            VStack(spacing: 8) {
                ForEach(SettingsPane.allCases) { pane in
                    SettingsSidebarPaneButton(
                        pane: pane,
                        isSelected: selectedPane == pane
                    ) {
                        selectedPane = pane
                    }
                }
            }
            .padding(.top, 16)

            Spacer()

            Text("Command+W 关闭窗口，Command+Q 退出应用。")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
                .padding(.top, 18)
        }
        .padding(18)
        .frame(width: 280, alignment: .topLeading)
        .background(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.58),
                    Color.white.opacity(0.42),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(Color.black.opacity(0.06))
                .frame(width: 0.6)
        }
    }

    @ViewBuilder
    private func detailView(for pane: SettingsPane) -> some View {
        switch pane {
        case .pet:
            PetSettingsDetailView(coordinator: coordinator)
        case .plugins:
            PluginSettingsDetailView(coordinator: coordinator)
        case .appearance:
            AppearanceSettingsDetailView()
        case .about:
            AboutSettingsDetailView()
        }
    }
}

private struct PetSettingsDetailView: View {
    @ObservedObject var coordinator: AppCoordinator
    @State private var leftColumnHeight: CGFloat = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SettingsHeroCard(
                    eyebrow: "Desktop Pet",
                    title: "桌宠",
                    subtitle: "切换当前宠物、预览姿势并调整尺寸，所有变更都会即时同步到桌面上的桌宠。",
                    accessory: {
                        VStack(alignment: .leading, spacing: 10) {
                            if let currentPet = coordinator.currentPet {
                                SettingsInfoPill(label: "当前宠物", value: currentPet.name)
                            }
                            SettingsInfoPill(
                                label: "当前尺寸",
                                value: "\(Int((coordinator.currentScale * 100).rounded()))%"
                            )
                        }
                    },
                    actions: {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 10) {
                                Button("导入宠物", action: coordinator.importPetArchive)
                                    .buttonStyle(SettingsActionButtonStyle(tint: .accentColor))
                                Button("打开插件面板", action: coordinator.openPluginPanel)
                                    .buttonStyle(SettingsActionButtonStyle(tint: .accentColor, isFilled: false))
                                Button("重置位置", action: coordinator.resetPetPosition)
                                    .buttonStyle(SettingsActionButtonStyle(tint: .accentColor, isFilled: false))
                            }

                            HStack(spacing: 10) {
                                if coordinator.canDeleteCurrentImportedPet {
                                    Button("删除该宠物", role: .destructive, action: coordinator.deleteCurrentImportedPetWithFeedback)
                                        .buttonStyle(SettingsActionButtonStyle(tint: .red))
                                }

                                Button("退出", role: .destructive) {
                                    NSApplication.shared.terminate(nil)
                                }
                                .buttonStyle(SettingsActionButtonStyle(tint: .red, isFilled: false))
                            }
                        }
                    }
                )

                if let petManagementStatus = coordinator.petManagementStatus {
                    PetManagementStatusBanner(status: petManagementStatus) {
                        coordinator.clearPetManagementStatus()
                    }
                }

                if let currentPet = coordinator.currentPet {
                    HStack(alignment: .top, spacing: 20) {
                        VStack(spacing: 20) {
                            SettingsSectionCard(
                                title: "当前宠物",
                                subtitle: "切换后会立即同步到桌面上的当前角色。"
                            ) {
                                PetPickerView(
                                    pets: coordinator.availablePets,
                                    selectedPetName: currentPet.name,
                                    sourceTitle: coordinator.currentPetSourceDisplayTitle,
                                    onSelect: coordinator.updateSelectedPet
                                )
                            }

                            SettingsSectionCard(
                                title: "大小",
                                subtitle: "调整缩放比例并同步预览与桌面桌宠。"
                            ) {
                                SizeControlView(
                                    scale: coordinator.currentScale,
                                    onChangeScale: coordinator.updateScale
                                )
                            }
                        }
                        .frame(width: 320)
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .preference(key: PetSettingsLeftColumnHeightPreferenceKey.self, value: proxy.size.height)
                            }
                        )

                        SettingsSectionCard(
                            title: "姿势预览",
                            subtitle: "左爬墙会自动使用右爬墙镜像；预览尺寸会跟随当前缩放同步调整。",
                            prominence: .featured
                        ) {
                            PosePreviewView(
                                pet: currentPet,
                                selectedState: coordinator.previewStateName,
                                scale: coordinator.currentScale,
                                onSelectState: coordinator.updatePreviewState
                            )
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: leftColumnHeight > 0 ? leftColumnHeight : nil)
                    }
                    .onPreferenceChange(PetSettingsLeftColumnHeightPreferenceKey.self) { value in
                        leftColumnHeight = value
                    }
                }
            }
            .padding(28)
        }
        .scrollIndicators(.visible)
    }
}

private struct PetManagementStatusBanner: View {
    let status: PetManagementStatus
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: status.kind == .success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(status.kind == .success ? Color.green : Color.red)

            Text(status.message)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)

            Spacer()

            Button("关闭", action: onDismiss)
                .buttonStyle(SettingsActionButtonStyle(
                    tint: status.kind == .success ? .green : .red,
                    isFilled: false
                ))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.82))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.white.opacity(0.72), lineWidth: 1)
        )
    }
}

private struct PetSettingsLeftColumnHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct AppearanceSettingsDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SettingsHeroCard(
                    eyebrow: "Window Experience",
                    title: "外观",
                    subtitle: "当前版本优先保证桌宠窗口的原生感与流畅交互，避免过度装饰干扰桌面使用。",
                    accessory: {
                        VStack(alignment: .leading, spacing: 10) {
                            SettingsInfoPill(label: "桌宠窗口", value: "透明悬浮")
                            SettingsInfoPill(label: "应用形态", value: "菜单栏常驻")
                        }
                    },
                    actions: {
                        EmptyView()
                    }
                )

                HStack(alignment: .top, spacing: 20) {
                    SettingsSectionCard(
                        title: "窗口表现",
                        subtitle: "保持桌面无感，但交互区域始终清晰。"
                    ) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("桌宠窗口默认使用透明、无边框、非 Mission Control 展示的表现形式。")
                            Text("非角色区域支持鼠标穿透，仅角色区域可点击或拖拽。")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    SettingsSectionCard(
                        title: "应用切换",
                        subtitle: "设置窗口打开时显式出现，关闭后恢复常驻代理形态。"
                    ) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("设置窗口打开后会显示 Dock 图标，便于原生窗口管理。")
                            Text("关闭设置后自动回到菜单栏代理模式，桌宠继续驻留桌面。")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(28)
        }
        .scrollIndicators(.visible)
    }
}

private struct AboutSettingsDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SettingsHeroCard(
                    eyebrow: "Desktop Pet",
                    title: "关于",
                    subtitle: "面向 macOS 的原生桌宠重写版本，重点放在贴边动作、插件面板与流畅交互。",
                    accessory: {
                        VStack(alignment: .leading, spacing: 10) {
                            SettingsInfoPill(label: "平台", value: "macOS")
                            SettingsInfoPill(label: "技术栈", value: "SwiftUI + AppKit")
                        }
                    },
                    actions: {
                        EmptyView()
                    }
                )

                HStack(alignment: .top, spacing: 20) {
                    SettingsSectionCard(
                        title: "应用信息",
                        subtitle: "当前版本聚焦于单宠物与桌面效率集成。"
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            LabeledContent("应用名称") {
                                Text("Desktop Pet")
                            }
                            LabeledContent("插件能力") {
                                Text("支持多个网页插件切换与排序")
                                    .foregroundStyle(.secondary)
                            }
                            LabeledContent("桌宠能力") {
                                Text("边缘吸附、拖拽、点击展开面板")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    SettingsSectionCard(
                        title: "实现原则",
                        subtitle: "优先保证原生感、可维护性和桌面使用体验。"
                    ) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("使用 SwiftUI + AppKit bridge 组合实现透明桌宠窗口与设置窗口。")
                            Text("网页面板采用 WebKit 承载，并保留登录态与响应式能力。")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(28)
        }
        .scrollIndicators(.visible)
    }
}
