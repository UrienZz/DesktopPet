import SwiftUI

struct SettingsRootView: View {
    @ObservedObject var coordinator: AppCoordinator
    @State private var selectedPane: SettingsPane = .pet

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            Divider()
            detailView(for: selectedPane)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(minWidth: 980, minHeight: 720)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("设置")
                .font(.title2.bold())
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

            VStack(spacing: 6) {
                ForEach(SettingsPane.allCases) { pane in
                    Button {
                        selectedPane = pane
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: pane.systemImage)
                                .frame(width: 18)
                            Text(pane.title)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(selectedPane == pane ? Color.accentColor : .clear)
                        )
                        .foregroundStyle(selectedPane == pane ? .white : .primary)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)

            Spacer()
        }
        .frame(width: 240, alignment: .topLeading)
        .background(Color(nsColor: .controlBackgroundColor))
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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SettingsDetailHeader(title: "桌宠", subtitle: "切换当前宠物、预览姿势并调整尺寸。")

                if let currentPet = coordinator.currentPet {
                    SettingsSectionCard(title: "当前宠物") {
                        PetPickerView(
                            pets: coordinator.availablePets,
                            selectedPetName: currentPet.name,
                            onSelect: coordinator.updateSelectedPet
                        )
                    }

                    SettingsSectionCard(title: "姿势预览") {
                        PosePreviewView(
                            pet: currentPet,
                            selectedState: coordinator.previewStateName,
                            scale: coordinator.currentScale,
                            onSelectState: coordinator.updatePreviewState
                        )
                    }
                }

                SettingsSectionCard(title: "大小") {
                    SizeControlView(
                        scale: coordinator.currentScale,
                        onChangeScale: coordinator.updateScale
                    )
                }

                SettingsSectionCard(title: "动作") {
                    SettingsActionsView(
                        onOpenPluginPanel: coordinator.openPluginPanel,
                        onResetPosition: coordinator.resetPetPosition,
                        onQuit: { NSApplication.shared.terminate(nil) }
                    )
                }
            }
            .padding(24)
        }
        .scrollIndicators(.visible)
    }
}

private struct AppearanceSettingsDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SettingsDetailHeader(title: "外观", subtitle: "当前版本优先保证桌宠窗口的原生感和流畅交互。")

                SettingsSectionCard(title: "说明") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("桌宠窗口当前默认采用透明、无边框、菜单栏常驻的表现形式。")
                        Text("设置窗口打开时显示 Dock 图标，关闭后恢复为常驻代理形态。")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
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
            VStack(alignment: .leading, spacing: 20) {
                SettingsDetailHeader(title: "关于", subtitle: "macOS 原生桌宠重写版本。")

                SettingsSectionCard(title: "应用信息") {
                    VStack(alignment: .leading, spacing: 12) {
                        LabeledContent("应用名称") {
                            Text("Desktop Pet")
                        }
                        LabeledContent("技术栈") {
                            Text("SwiftUI + AppKit + WebKit")
                                .foregroundStyle(.secondary)
                        }
                        LabeledContent("特性") {
                            Text("单宠物、边缘吸附、插件面板、菜单栏入口")
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

struct SettingsDetailHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.largeTitle.bold())
            Text(subtitle)
                .foregroundStyle(.secondary)
        }
    }
}

struct SettingsSectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)
            content
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 1)
        )
    }
}
