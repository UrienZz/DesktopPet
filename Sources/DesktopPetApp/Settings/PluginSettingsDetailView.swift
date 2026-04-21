import SwiftUI
import UniformTypeIdentifiers

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
            VStack(alignment: .leading, spacing: 20) {
                SettingsDetailHeader(title: "插件", subtitle: "管理网页插件、拖拽排序，并配置点击宠物后展开的面板内容。")

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
                    .frame(width: 320)

                    SettingsSectionCard(title: "插件配置") {
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
                    .onTapGesture {
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
                .buttonStyle(PluginActionButtonStyle(tint: .accentColor, graysWhenInactive: true))
        }
    }
}

private struct PluginRowView: View {
    let plugin: PluginConfiguration
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "line.3.horizontal")
                .foregroundStyle(.secondary)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 4) {
                Text(plugin.name)
                    .font(.headline)
                Text(plugin.isEnabled ? "已启用" : "已禁用")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if !plugin.iconName.isEmpty {
                Image(systemName: plugin.iconName)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isSelected ? Color.accentColor.opacity(0.14) : Color(nsColor: .windowBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(
                    isSelected ? Color.accentColor : Color(nsColor: .quaternaryLabelColor),
                    lineWidth: 1
                )
        )
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
            VStack(alignment: .leading, spacing: 14) {
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

                Toggle("启用此插件", isOn: $draftEnabled)

                if let validationMessage {
                    Text(validationMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                HStack {
                    Button("保存", action: onSave)
                        .buttonStyle(PluginActionButtonStyle(tint: .accentColor, graysWhenInactive: true))
                    Button("删除", role: .destructive, action: onDelete)
                        .buttonStyle(PluginActionButtonStyle(tint: .red, graysWhenInactive: false))
                }

                Text("排序通过左侧列表中的三横杠拖拽把手完成。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } else {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "puzzlepiece.extension")
                    .font(.system(size: 24))
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

private struct PluginActionButtonStyle: ButtonStyle {
    @Environment(\.controlActiveState) private var controlActiveState

    let tint: Color
    let graysWhenInactive: Bool

    func makeBody(configuration: Configuration) -> some View {
        let resolvedTint = graysWhenInactive && controlActiveState == .inactive
            ? Color(nsColor: .systemGray)
            : tint

        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(configuration.isPressed ? resolvedTint.opacity(0.82) : resolvedTint)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(resolvedTint.opacity(0.28), lineWidth: 1)
            )
    }
}
