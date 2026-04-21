import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct PluginSettingsDetailView: View {
    @ObservedObject var coordinator: AppCoordinator
    @State private var draftName = ""
    @State private var draftURL = ""
    @State private var draftIconName = ""
    @State private var draftEnabled = true
    @State private var validationMessage: String?
    @State private var draggedPluginID: UUID?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SettingsHeroCard(
                    eyebrow: "Plugin Workspace",
                    title: "插件",
                    subtitle: "管理网页插件、拖拽排序，并配置点击宠物后展开的面板内容。",
                    accessory: {
                        VStack(alignment: .leading, spacing: 10) {
                            SettingsInfoPill(label: "插件总数", value: "\(coordinator.plugins.count)")
                            SettingsInfoPill(label: "已启用", value: "\(coordinator.plugins.filter(\.isEnabled).count)")
                        }
                    },
                    actions: {
                        Button("新增插件", action: coordinator.addPlugin)
                            .buttonStyle(SettingsActionButtonStyle(tint: .accentColor, graysWhenInactive: true))
                    }
                )

                HStack(alignment: .top, spacing: 20) {
                    SettingsSectionCard(
                        title: "插件列表",
                        subtitle: "左侧用于选择与拖拽排序，支持 hover 高亮与手型提示。"
                    ) {
                        PluginListView(
                            plugins: coordinator.plugins,
                            selectedPluginID: coordinator.selectedPluginID,
                            draggedPluginID: $draggedPluginID,
                            onSelect: coordinator.selectPlugin,
                            onMove: coordinator.movePlugin(sourceID:before:),
                            onAdd: coordinator.addPlugin
                        )
                    }
                    .frame(width: 340)

                    SettingsSectionCard(
                        title: "插件配置",
                        subtitle: "配置名称、网址、图标与启用状态。",
                        prominence: .featured
                    ) {
                        PluginEditorView(
                            hasSelection: coordinator.selectedPlugin != nil,
                            draftName: $draftName,
                            draftURL: $draftURL,
                            draftIconName: $draftIconName,
                            draftEnabled: $draftEnabled,
                            validationMessage: validationMessage,
                            onSave: saveDraft,
                            onDelete: coordinator.deleteSelectedPlugin
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(28)
        }
        .scrollIndicators(.visible)
        .onAppear(perform: syncDraftFromSelection)
        .onChange(of: coordinator.selectedPluginID) { _ in
            syncDraftFromSelection()
        }
    }

    private func saveDraft() {
        validationMessage = nil
        if coordinator.updateSelectedPlugin(
            name: draftName,
            urlString: draftURL,
            iconName: draftIconName,
            isEnabled: draftEnabled
        ) == false {
            validationMessage = "请输入有效名称与网址。"
        }
    }

    private func syncDraftFromSelection() {
        guard let plugin = coordinator.selectedPlugin else {
            draftName = ""
            draftURL = ""
            draftIconName = ""
            draftEnabled = true
            validationMessage = nil
            return
        }

        draftName = plugin.name
        draftURL = plugin.url.absoluteString
        draftIconName = plugin.iconName
        draftEnabled = plugin.isEnabled
        validationMessage = nil
    }
}

private struct PluginListView: View {
    let plugins: [PluginConfiguration]
    let selectedPluginID: UUID?
    @Binding var draggedPluginID: UUID?
    let onSelect: (UUID?) -> Void
    let onMove: (UUID, UUID) -> Void
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(spacing: 10) {
                ForEach(plugins) { plugin in
                    PluginRowView(
                        plugin: plugin,
                        isSelected: plugin.id == selectedPluginID
                    )
                    .onSelect {
                        onSelect(plugin.id)
                    }
                    .onDrag {
                        draggedPluginID = plugin.id
                        return NSItemProvider(object: plugin.id.uuidString as NSString)
                    }
                    .onDrop(
                        of: [UTType.text],
                        delegate: PluginRowDropDelegate(
                            targetPluginID: plugin.id,
                            draggedPluginID: $draggedPluginID,
                            onMove: onMove
                        )
                    )
                }
            }

            Button("新增插件", action: onAdd)
                .buttonStyle(SettingsActionButtonStyle(tint: .accentColor, graysWhenInactive: true))
        }
    }
}

private struct PluginRowView: View {
    let plugin: PluginConfiguration
    let isSelected: Bool

    @State private var isHovered = false
    @State private var isPointerActive = false

    private var appearance: PluginSidebarRowAppearance {
        PluginSidebarRowAppearance.resolve(
            isSelected: isSelected,
            isHovered: isHovered,
            isPressed: false
        )
    }

    var body: some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.accentColor.opacity(appearance.leadingIndicatorOpacity))
                    .frame(width: 4, height: 28)

                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.accentColor.opacity(appearance.iconTileOpacity))
                    .frame(width: 30, height: 30)
                    .overlay {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text(plugin.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text(plugin.isEnabled ? "已启用" : "已禁用")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(plugin.isEnabled ? Color.accentColor : .secondary)
                }

                Spacer()

                if !plugin.iconName.isEmpty {
                    Image(systemName: plugin.iconName)
                        .foregroundStyle(isSelected ? Color.accentColor : .secondary.opacity(isHovered ? 0.84 : 0.66))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.accentColor.opacity(appearance.backgroundOpacity))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.accentColor.opacity(appearance.borderOpacity), lineWidth: 1)
            )
            .shadow(color: .black.opacity(appearance.shadowOpacity), radius: isHovered ? 10 : 6, y: isHovered ? 5 : 3)
        }
        .buttonStyle(PluginSettingsRowButtonStyle(isSelected: isSelected, isHovered: isHovered))
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onHover(perform: updateHoverState)
        .onDisappear {
            if isPointerActive {
                NSCursor.pop()
                isPointerActive = false
            }
        }
        .animation(.easeOut(duration: 0.16), value: isHovered)
        .animation(.easeOut(duration: 0.16), value: isSelected)
    }

    private func updateHoverState(_ hovering: Bool) {
        isHovered = hovering

        if hovering {
            guard !isPointerActive else { return }
            NSCursor.pointingHand.push()
            isPointerActive = true
        } else if isPointerActive {
            NSCursor.pop()
            isPointerActive = false
        }
    }
}

private struct PluginEditorView: View {
    let hasSelection: Bool
    @Binding var draftName: String
    @Binding var draftURL: String
    @Binding var draftIconName: String
    @Binding var draftEnabled: Bool
    let validationMessage: String?
    let onSave: () -> Void
    let onDelete: () -> Void

    var body: some View {
        if hasSelection {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("插件名称")
                        .font(.subheadline.weight(.medium))
                    TextField("请输入插件名称", text: $draftName)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("插件网址")
                        .font(.subheadline.weight(.medium))
                    TextField("请输入完整网址", text: $draftURL)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("图标标识")
                        .font(.subheadline.weight(.medium))
                    TextField("请输入 SF Symbols 名称", text: $draftIconName)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("启用状态")
                        .font(.subheadline.weight(.medium))
                    Toggle("启用此插件", isOn: $draftEnabled)
                }

                if let validationMessage {
                    Text(validationMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                HStack {
                    Button("保存", action: onSave)
                        .buttonStyle(SettingsActionButtonStyle(tint: .accentColor, graysWhenInactive: true))
                    Button("删除", role: .destructive, action: onDelete)
                        .buttonStyle(SettingsActionButtonStyle(tint: .red))
                }

                Text("排序通过左侧列表中的三横杠拖拽把手完成。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } else {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "puzzlepiece.extension")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
                Text("请选择一个插件，或先新增插件。")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct PluginRowDropDelegate: DropDelegate {
    let targetPluginID: UUID
    @Binding var draggedPluginID: UUID?
    let onMove: (UUID, UUID) -> Void

    func dropEntered(info: DropInfo) {
        guard let draggedPluginID else { return }
        onMove(draggedPluginID, targetPluginID)
    }

    func performDrop(info: DropInfo) -> Bool {
        draggedPluginID = nil
        return true
    }
}

private struct PluginSettingsRowButtonStyle: ButtonStyle {
    let isSelected: Bool
    let isHovered: Bool

    func makeBody(configuration: Configuration) -> some View {
        let appearance = PluginSidebarRowAppearance.resolve(
            isSelected: isSelected,
            isHovered: isHovered,
            isPressed: configuration.isPressed
        )

        return configuration.label
            .scaleEffect(appearance.scale)
            .brightness(configuration.isPressed ? -0.01 : 0)
    }
}

private extension View {
    func onSelect(_ action: @escaping () -> Void) -> some View {
        simultaneousGesture(
            TapGesture().onEnded {
                action()
            }
        )
    }
}
