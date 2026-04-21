import SwiftUI

struct PluginPanelView: View {
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            content
        }
        .frame(minWidth: AppConstants.panelSize.width, minHeight: AppConstants.panelSize.height)
    }

    @ViewBuilder
    private var sidebar: some View {
        if coordinator.isPluginSidebarExpanded {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("插件")
                        .font(.headline)
                    Spacer()
                    Button(action: coordinator.togglePluginSidebar) {
                        Image(systemName: "sidebar.left")
                    }
                    .buttonStyle(.plain)
                }

                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(coordinator.visiblePlugins) { plugin in
                            Button {
                                coordinator.selectPanelPlugin(plugin.id)
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: plugin.iconName.isEmpty ? "puzzlepiece.extension" : plugin.iconName)
                                        .frame(width: 18)
                                    Text(plugin.name)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(plugin.id == coordinator.selectedPanelPluginID ? Color.accentColor.opacity(0.16) : .clear)
                                )
                            }
                            .buttonStyle(.plain)
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
                Button(action: coordinator.togglePluginSidebar) {
                    Image(systemName: "sidebar.right")
                        .font(.title3)
                }
                .buttonStyle(.plain)
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
            PluginWebView(url: plugin.url)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            PluginEmptyStateView()
        }
    }
}
