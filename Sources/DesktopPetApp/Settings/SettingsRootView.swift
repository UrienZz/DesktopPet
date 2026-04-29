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
        .frame(minWidth: AppConstants.settingsWindowSize.width, minHeight: AppConstants.settingsWindowSize.height)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var sidebar: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                VStack(spacing: SettingsSidebarLayout.rowSpacing) {
                    ForEach(SettingsPane.allCases) { pane in
                        SettingsSidebarPaneButton(
                            pane: pane,
                            isSelected: selectedPane == pane
                        ) {
                            selectedPane = pane
                        }
                    }
                }
                .padding(.top, SettingsSidebarLayout.topPadding)

                Spacer()
            }
            .padding(.horizontal, SettingsSidebarLayout.horizontalPadding)
            .frame(width: SettingsSidebarLayout.width, alignment: .topLeading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: SettingsSidebarLayout.panelCornerRadius, style: .continuous))
            .background(
                RoundedRectangle(cornerRadius: SettingsSidebarLayout.panelCornerRadius, style: .continuous)
                    .fill(Color(nsColor: .underPageBackgroundColor).opacity(SettingsSidebarLayout.panelBackgroundOpacity))
            )
            .overlay(
                RoundedRectangle(cornerRadius: SettingsSidebarLayout.panelCornerRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.42), lineWidth: 1)
            )
            .shadow(color: .black.opacity(SettingsSidebarLayout.panelShadowOpacity), radius: SettingsSidebarLayout.panelShadowRadius, y: 12)
            .padding(SettingsSidebarLayout.outerPadding)

            Spacer(minLength: 0)
        }
        .frame(width: SettingsSidebarLayout.containerWidth, alignment: .leading)
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
                SettingsPageHeader(title: "桌宠")

                HStack(spacing: 10) {
                    Button("导入宠物", action: coordinator.importPetArchive)
                        .buttonStyle(SettingsActionButtonStyle(tint: .accentColor))
                    Button("打开插件面板", action: coordinator.openPluginPanel)
                        .buttonStyle(SettingsActionButtonStyle(tint: .accentColor, isFilled: false))
                    Button("重置位置", action: coordinator.resetPetPosition)
                        .buttonStyle(SettingsActionButtonStyle(tint: .accentColor, isFilled: false))
                    if coordinator.canDeleteCurrentImportedPet {
                        Button("删除该宠物", role: .destructive, action: coordinator.deleteCurrentImportedPetWithFeedback)
                            .buttonStyle(SettingsActionButtonStyle(tint: .red))
                    }
                    Spacer()
                }
                .padding(.top, -10)

                if let petManagementStatus = coordinator.petManagementStatus {
                    PetManagementStatusBanner(status: petManagementStatus) {
                        coordinator.clearPetManagementStatus()
                    }
                }

                if let currentPet = coordinator.currentPet {
                    HStack(alignment: .top, spacing: 18) {
                        VStack(spacing: 20) {
                            SettingsSectionCard(title: "当前宠物") {
                                PetPickerView(
                                    pets: coordinator.availablePets,
                                    selectedPetName: currentPet.name,
                                    sourceTitle: coordinator.currentPetSourceDisplayTitle,
                                    onSelect: coordinator.updateSelectedPet
                                )
                            }

                            SettingsSectionCard(title: "大小") {
                                SizeControlView(
                                    scale: coordinator.currentScale,
                                    onChangeScale: coordinator.updateScale
                                )
                            }
                        }
                        .frame(width: 280)
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .preference(key: PetSettingsLeftColumnHeightPreferenceKey.self, value: proxy.size.height)
                            }
                        )

                        SettingsSectionCard(
                            title: "姿势预览",
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
            .padding(24)
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
                SettingsPageHeader(title: "外观")

                HStack(alignment: .top, spacing: 20) {
                    SettingsSectionCard(title: "窗口表现") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("桌宠窗口默认使用透明、无边框、非 Mission Control 展示的表现形式。")
                            Text("非角色区域支持鼠标穿透，仅角色区域可点击或拖拽。")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    SettingsSectionCard(title: "应用切换") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("设置窗口打开后会显示 Dock 图标，便于原生窗口管理。")
                            Text("关闭设置后自动回到菜单栏代理模式，桌宠继续驻留桌面。")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(24)
        }
        .scrollIndicators(.visible)
    }
}

private struct AboutSettingsDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SettingsPageHeader(title: "关于")

                HStack(alignment: .top, spacing: 20) {
                    SettingsSectionCard(title: "应用信息") {
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

                    SettingsSectionCard(title: "实现原则") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("使用 SwiftUI + AppKit bridge 组合实现透明桌宠窗口与设置窗口。")
                            Text("网页面板采用 WebKit 承载，并保留登录态与响应式能力。")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(24)
        }
        .scrollIndicators(.visible)
    }
}
