import SwiftUI
import AppKit

struct PluginPanelView: View {
    @ObservedObject var coordinator: AppCoordinator
    @StateObject private var selectionState = PluginPanelSelectionState()
    @State private var webViewCache = PluginWebViewCache()

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            content
        }
        .frame(minWidth: AppConstants.panelSize.width, minHeight: AppConstants.panelSize.height)
        .onAppear(perform: syncPanelState)
        .onChange(of: coordinator.visiblePlugins) { _ in
            syncPanelState()
        }
        .onChange(of: coordinator.selectedPanelPluginID) { _ in
            syncPanelState()
        }
    }

    @ViewBuilder
    private var sidebar: some View {
        if coordinator.isPluginSidebarExpanded {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("插件")
                        .font(.headline)
                    Spacer()
                    SidebarToggleButton(iconName: "sidebar.left", action: coordinator.togglePluginSidebar)
                }

                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(coordinator.visiblePlugins) { plugin in
                            PluginSidebarRowButton(
                                plugin: plugin,
                                isSelected: plugin.id == coordinator.selectedPanelPluginID
                            ) {
                                coordinator.selectPanelPlugin(plugin.id)
                            }
                        }
                    }
                }
            }
            .padding(14)
            .frame(width: 220)
            .frame(maxHeight: .infinity, alignment: .topLeading)
            .background(Color(nsColor: .controlBackgroundColor))
        } else {
            VStack {
                SidebarToggleButton(iconName: "sidebar.right", action: coordinator.togglePluginSidebar)
                .padding(.top, 14)
                Spacer()
            }
            .frame(width: 54)
            .frame(maxHeight: .infinity)
            .background(Color(nsColor: .controlBackgroundColor))
        }
    }

    @ViewBuilder
    private var content: some View {
        if let plugin = coordinator.selectedPanelPlugin {
            ZStack {
                PluginWebView(
                    webView: webViewCache.webView(
                        for: plugin,
                        onLoadStart: { pluginID in
                            selectionState.markStartedLoading(pluginID: pluginID)
                        },
                        onLoadFinish: { pluginID, url in
                            selectionState.markFinishedLoading(pluginID: pluginID, url: url)
                        },
                        onLoadFail: { pluginID in
                            selectionState.markFailedLoading(pluginID: pluginID)
                        }
                    )
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if selectionState.isLoading {
                    loadingOverlay
                }
            }
        } else {
            PluginEmptyStateView()
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.04)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                ProgressView()
                    .controlSize(.regular)
                Text("正在加载插件内容…")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .transition(.opacity)
    }

    private func syncPanelState() {
        webViewCache.reconcile(with: coordinator.visiblePlugins)
        selectionState.syncSelection(
            availablePlugins: coordinator.visiblePlugins,
            preferredPluginID: coordinator.selectedPanelPluginID
        )
    }
}

private struct PluginSidebarRowButton: View {
    let plugin: PluginConfiguration
    let isSelected: Bool
    let action: () -> Void

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
        Button {
            withAnimation(.easeOut(duration: 0.14)) {
                action()
            }
        } label: {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(Color.accentColor.opacity(appearance.leadingIndicatorOpacity))
                    .frame(width: 4, height: 30)

                iconTile

                VStack(alignment: .leading, spacing: 3) {
                    Text(plugin.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(isSelected ? Color.primary : Color.primary.opacity(isHovered ? 0.92 : 0.82))
                        .lineLimit(1)

                    Text(isSelected ? "当前展示" : "点击切换")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                }

                Spacer(minLength: 12)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary.opacity(isHovered ? 0.85 : 0.45))
                    .offset(x: isHovered ? 1.5 : 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.accentColor.opacity(appearance.backgroundOpacity))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        Color.accentColor.opacity(appearance.borderOpacity),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: .black.opacity(appearance.shadowOpacity),
                radius: isHovered ? 10 : 6,
                y: isHovered ? 5 : 3
            )
        }
        .buttonStyle(PluginSidebarRowButtonStyle(isHovered: isHovered, isSelected: isSelected))
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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

    private var iconTile: some View {
        RoundedRectangle(cornerRadius: 11, style: .continuous)
            .fill(Color.accentColor.opacity(appearance.iconTileOpacity))
            .frame(width: 34, height: 34)
            .overlay {
                Image(systemName: plugin.iconName.isEmpty ? "puzzlepiece.extension" : plugin.iconName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.accentColor : .primary.opacity(isHovered ? 0.84 : 0.66))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .strokeBorder(Color.white.opacity(isHovered ? 0.32 : 0.16), lineWidth: 0.8)
            }
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

private struct PluginSidebarRowButtonStyle: ButtonStyle {
    let isHovered: Bool
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        let appearance = PluginSidebarRowAppearance.resolve(
            isSelected: isSelected,
            isHovered: isHovered,
            isPressed: configuration.isPressed
        )

        return configuration.label
            .scaleEffect(appearance.scale)
            .brightness(configuration.isPressed ? -0.01 : 0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

private struct SidebarToggleButton: View {
    let iconName: String
    let action: () -> Void

    @State private var isHovered = false
    @State private var isPointerActive = false

    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isHovered ? .primary : .secondary)
                .frame(width: 30, height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.accentColor.opacity(isHovered ? 0.12 : 0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.accentColor.opacity(isHovered ? 0.18 : 0.08), lineWidth: 1)
                )
                .scaleEffect(isHovered ? 1.02 : 1)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
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
        .onDisappear {
            if isPointerActive {
                NSCursor.pop()
                isPointerActive = false
            }
        }
        .animation(.easeOut(duration: 0.14), value: isHovered)
    }
}
