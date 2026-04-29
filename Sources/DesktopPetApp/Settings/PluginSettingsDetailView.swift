import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct PluginSettingsDetailView: View {
    @ObservedObject var coordinator: AppCoordinator
    @State private var draftName = ""
    @State private var draftURL = ""
    @State private var draftIconName = ""
    @State private var selectedIconOptionID = AppConstants.defaultPluginIconName
    @State private var draftEnabled = true
    @State private var validationMessage: String?
    @State private var draggedPluginID: UUID?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SettingsPageHeader(title: "插件")

                HStack {
                    Button("新增插件", action: coordinator.addPlugin)
                        .buttonStyle(SettingsActionButtonStyle(tint: .accentColor, graysWhenInactive: true))
                    Spacer()
                }
                .padding(.top, -10)

                HStack(alignment: .top, spacing: 20) {
                    SettingsSectionCard(title: "插件列表") {
                        PluginListView(
                            plugins: coordinator.plugins,
                            selectedPluginID: coordinator.selectedPluginID,
                            draggedPluginID: $draggedPluginID,
                            onSelect: coordinator.selectPlugin,
                            onMove: coordinator.movePlugin(sourceID:before:),
                            onAdd: coordinator.addPlugin
                        )
                    }
                    .frame(width: 300)

                    SettingsSectionCard(
                        title: "插件配置",
                        prominence: .featured
                    ) {
                        PluginEditorView(
                            hasSelection: coordinator.selectedPlugin != nil,
                            draftName: $draftName,
                            draftURL: $draftURL,
                            draftIconName: $draftIconName,
                            selectedIconOptionID: $selectedIconOptionID,
                            draftEnabled: $draftEnabled,
                            validationMessage: validationMessage,
                            onSave: saveDraft,
                            onDelete: coordinator.deleteSelectedPlugin
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(24)
        }
        .scrollIndicators(.visible)
        .onAppear(perform: syncDraftFromSelection)
        .onChange(of: coordinator.selectedPluginID) { _ in
            syncDraftFromSelection()
        }
    }

    private func saveDraft() {
        validationMessage = nil
        let resolvedIconName = PluginIconCatalog.resolvedIconName(
            selectionID: selectedIconOptionID,
            customIconName: draftIconName
        )

        guard !resolvedIconName.isEmpty else {
            validationMessage = "请选择图标，或输入有效的自定义 SF Symbol 名称。"
            return
        }

        if coordinator.updateSelectedPlugin(
            name: draftName,
            urlString: draftURL,
            iconName: resolvedIconName,
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
            selectedIconOptionID = AppConstants.defaultPluginIconName
            draftEnabled = true
            validationMessage = nil
            return
        }

        draftName = plugin.name
        draftURL = plugin.url.absoluteString
        draftIconName = plugin.iconName
        selectedIconOptionID = PluginIconCatalog.selectionID(for: plugin.iconName)
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
    @Binding var selectedIconOptionID: String
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
                    Text("插件图标")
                        .font(.subheadline.weight(.medium))
                    PluginIconPickerView(
                        selectedIconOptionID: $selectedIconOptionID,
                        customIconName: $draftIconName
                    )
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

private struct PluginIconPickerView: View {
    @Binding var selectedIconOptionID: String
    @Binding var customIconName: String

    private var displayIconName: String {
        PluginIconCatalog.displayIconName(
            selectionID: selectedIconOptionID,
            customIconName: customIconName
        )
    }

    private var currentOptionTitle: String {
        PluginIconCatalog.option(for: selectedIconOptionID)?.title ?? "自定义图标"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 42, height: 42)
                    .overlay {
                        Image(systemName: displayIconName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.accentColor)
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text(currentOptionTitle)
                        .font(.system(size: 13, weight: .semibold))
                    Text(displayIconName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }

            Picker("插件图标", selection: $selectedIconOptionID) {
                ForEach(PluginIconCatalog.options) { option in
                    Label(option.title, systemImage: option.iconName)
                        .tag(option.id)
                }
            }
            .pickerStyle(.menu)

            if selectedIconOptionID == PluginIconCatalog.customOptionID {
                VStack(alignment: .leading, spacing: 6) {
                    Text("自定义 SF Symbol")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                    TextField("请输入图标名称，如 tray.fill", text: $customIconName)
                        .textFieldStyle(.roundedBorder)
                }
            }
        }
        .onChange(of: selectedIconOptionID) { newValue in
            guard newValue != PluginIconCatalog.customOptionID else { return }
            customIconName = newValue
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
