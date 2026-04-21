import AppKit
import Foundation
import SwiftUI

@MainActor
final class AppCoordinator: NSObject, ObservableObject {
    private struct PetAnchorState {
        let position: CGPoint
        let mode: PetRuntimeMode
    }

    @Published private(set) var availablePets: [PetDefinition] = []
    @Published private(set) var currentPet: PetDefinition?
    @Published var currentScale: Double = AppConstants.defaultPetScale
    @Published var previewStateName: String = ""
    @Published private(set) var isPetAnimationPaused = false
    @Published private(set) var plugins: [PluginConfiguration] = []
    @Published private(set) var selectedPluginID: UUID?
    @Published private(set) var selectedPanelPluginID: UUID?
    @Published var isPluginSidebarExpanded = false

    private let catalogLoader = PetCatalogLoader()
    private let preferencesStore: AppPreferencesStore
    private let pluginStore: PluginStore

    private var runtimeController: PetRuntimeController?
    private var menuBarController: MenuBarController?
    private var petWindow: PetWindow?
    private var panelWindow: PanelWindow?
    private var settingsWindowController: SettingsWindowController?
    private var outsideClickMonitor: OutsideClickMonitor?
    private var trelloReturnState: PetAnchorState?

    init(
        preferencesStore: AppPreferencesStore = AppPreferencesStore(),
        pluginStore: PluginStore = PluginStore()
    ) {
        self.preferencesStore = preferencesStore
        self.pluginStore = pluginStore
        super.init()
    }

    func start() {
        do {
            availablePets = try catalogLoader.loadAllPets()
            guard let firstPet = availablePets.first else { return }
            let restoredScale = preferencesStore.loadPetScale(defaultValue: AppConstants.defaultPetScale)
            let restoredPetName = preferencesStore.loadSelectedPetName()
            let restoredAnimationPaused = preferencesStore.loadPetAnimationPaused()
            currentScale = restoredScale
            isPetAnimationPaused = restoredAnimationPaused
            plugins = try pluginStore.loadPlugins()
            selectedPluginID = plugins.first?.id
            selectedPanelPluginID = nil

            runtimeController = PetRuntimeController(
                availablePets: availablePets,
                initialScale: restoredScale,
                initialPetName: restoredPetName
            )
            currentPet = runtimeController?.currentPet ?? firstPet
            previewStateName = currentPet?.preferredStandingStateName ?? firstPet.preferredStandingStateName

            configureMainMenu()
            createMenuBarController()
            createPetWindow()
            enterAgentMode()
            resetPetPosition()
        } catch {
            assertionFailure("Failed to start DesktopPetApp: \(error)")
        }
    }

    func openSettings() {
        enterSettingsMode()

        if let settingsWindowController {
            settingsWindowController.showWindow(nil)
            settingsWindowController.window?.makeKeyAndOrderFront(nil)
            NSApplication.shared.activate(ignoringOtherApps: true)
            return
        }

        let rootView = SettingsRootView(coordinator: self)
        let controller = SettingsWindowController(rootView: rootView) { [weak self] in
            Task { @MainActor in
                self?.enterAgentMode()
            }
        }

        settingsWindowController = controller
        controller.showWindow(nil)
        controller.window?.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    func openPluginPanel() {
        guard let petWindow, let runtimeController else { return }

        if trelloReturnState == nil {
            trelloReturnState = PetAnchorState(
                position: runtimeController.currentPosition,
                mode: runtimeController.currentMode
            )
        }
        preparePluginPanelSelection()
        isPluginSidebarExpanded = false
        updatePetMode(.hovering)

        if let panelWindow {
            self.panelWindow = panelWindow
            panelWindow.show(anchoredTo: petWindow.frame)
            startOutsideClickMonitoring()
            return
        }

        let panelWindow = PanelWindow(rootView: PluginPanelView(coordinator: self)) { [weak self] in
            Task { @MainActor in
                self?.handlePanelWindowClosed()
            }
        }
        self.panelWindow = panelWindow
        panelWindow.show(anchoredTo: petWindow.frame)
        startOutsideClickMonitoring()
    }

    func showTrello() {
        openPluginPanel()
    }

    func hideTrelloAndRestorePet() {
        panelWindow?.orderOut(nil)
        outsideClickMonitor?.stop()
        outsideClickMonitor = nil
        restorePetAfterTrelloClose()
    }

    func resetPetPosition() {
        guard
            let runtimeController,
            let petWindow
        else { return }

        let screenFrame = petWindow.screen?.visibleFrame
            ?? NSScreen.main?.visibleFrame
            ?? CGRect(x: 0, y: 0, width: 1440, height: 900)
        let petSize = petWindow.frame.size
        runtimeController.resetToDefaultPosition(screenFrame: screenFrame, petSize: petSize)
        updatePublishedState()
        petWindow.setFrameOrigin(runtimeController.currentPosition)
        petWindow.renderView.runtimeMode = runtimeController.currentMode
    }

    func updateSelectedPet(_ petName: String) {
        guard let runtimeController else { return }
        runtimeController.selectPet(named: petName)
        preferencesStore.saveSelectedPetName(runtimeController.currentPet.name)
        currentPet = runtimeController.currentPet
        previewStateName = runtimeController.currentPet.preferredStandingStateName
        petWindow?.renderView.pet = runtimeController.currentPet
        petWindow?.renderView.runtimeMode = runtimeController.currentMode
    }

    func updateScale(_ scale: Double) {
        guard let runtimeController else { return }
        runtimeController.updateScale(scale)
        preferencesStore.savePetScale(scale)
        currentScale = scale
        petWindow?.renderView.scaleFactor = CGFloat(scale)
        petWindow?.resizeToFitContent()
        resetPetPosition()
    }

    func updatePreviewState(_ stateName: String) {
        previewStateName = stateName
    }

    func selectPlugin(_ pluginID: UUID?) {
        selectedPluginID = pluginID
    }

    func selectPanelPlugin(_ pluginID: UUID?) {
        selectedPanelPluginID = pluginID
    }

    func togglePluginSidebar() {
        isPluginSidebarExpanded.toggle()
    }

    func addPlugin() {
        let plugin = PluginConfiguration(
            id: UUID(),
            name: "未命名插件",
            url: AppConstants.defaultPluginURL,
            iconName: "puzzlepiece.extension",
            isEnabled: true,
            sortOrder: plugins.count
        )
        plugins.append(plugin)
        persistPlugins(selecting: plugin.id)
    }

    @discardableResult
    func updateSelectedPlugin(
        name: String,
        urlString: String,
        iconName: String,
        isEnabled: Bool
    ) -> Bool {
        guard
            let selectedPluginID,
            let index = plugins.firstIndex(where: { $0.id == selectedPluginID }),
            let url = URL(string: urlString),
            !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return false
        }

        plugins[index].name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        plugins[index].url = url
        plugins[index].iconName = iconName.trimmingCharacters(in: .whitespacesAndNewlines)
        plugins[index].isEnabled = isEnabled
        persistPlugins(selecting: selectedPluginID)
        return true
    }

    func deleteSelectedPlugin() {
        guard
            let selectedPluginID,
            let index = plugins.firstIndex(where: { $0.id == selectedPluginID })
        else {
            return
        }

        plugins.remove(at: index)
        let nextSelection = plugins.indices.contains(index) ? plugins[index].id : plugins.last?.id
        persistPlugins(selecting: nextSelection)
    }

    func movePlugins(from source: IndexSet, to destination: Int) {
        plugins.move(fromOffsets: source, toOffset: destination)
        let nextSelection = selectedPluginID
        persistPlugins(selecting: nextSelection)
    }

    func movePlugin(sourceID: UUID, before targetID: UUID) {
        guard
            sourceID != targetID,
            let sourceIndex = plugins.firstIndex(where: { $0.id == sourceID }),
            let targetIndex = plugins.firstIndex(where: { $0.id == targetID })
        else {
            return
        }

        let movingPlugin = plugins.remove(at: sourceIndex)
        let adjustedTargetIndex = sourceIndex < targetIndex ? max(0, targetIndex - 1) : targetIndex
        plugins.insert(movingPlugin, at: adjustedTargetIndex)
        persistPlugins(selecting: selectedPluginID)
    }

    func togglePetAnimationPaused() {
        isPetAnimationPaused.toggle()
        preferencesStore.savePetAnimationPaused(isPetAnimationPaused)
        petWindow?.renderView.isAnimationPaused = isPetAnimationPaused
        menuBarController?.updateAnimationMenu(isPaused: isPetAnimationPaused)
    }

    func handlePetDragEnded(windowOrigin: CGPoint) {
        guard
            let runtimeController,
            let petWindow
        else { return }

        let screenFrame = petWindow.screen?.visibleFrame
            ?? NSScreen.main?.visibleFrame
            ?? CGRect(x: 0, y: 0, width: 1440, height: 900)
        let petSize = petWindow.frame.size

        runtimeController.moveDraggedPet(to: windowOrigin)
        runtimeController.handleDrop(screenFrame: screenFrame, petSize: petSize)
        applyRuntimePositionAndMode()

        if runtimeController.currentMode == .falling {
            runtimeController.completeFallIfNeeded()
            applyRuntimePositionAndMode()
        }
    }

    func performWindowClose() {
        if panelWindow?.isVisible == true {
            hideTrelloAndRestorePet()
        } else {
            settingsWindowController?.close()
        }
    }

    private func createMenuBarController() {
        menuBarController = MenuBarController(
            onOpenSettings: { [weak self] in self?.openSettings() },
            onTogglePetAnimation: { [weak self] in self?.togglePetAnimationPaused() },
            isPetAnimationPaused: isPetAnimationPaused,
            onResetPet: { [weak self] in self?.resetPetPosition() },
            onQuit: { NSApplication.shared.terminate(nil) }
        )
    }

    private func createPetWindow() {
        guard let runtimeController else { return }

        let renderView = PetRenderView(
            pet: runtimeController.currentPet,
            runtimeMode: runtimeController.currentMode,
            scaleFactor: CGFloat(currentScale)
        )
        renderView.isAnimationPaused = isPetAnimationPaused
        renderView.onTap = { [weak self] in
            Task { @MainActor in
                self?.openPluginPanel()
            }
        }
        renderView.onDragEnded = { [weak self] origin in
            Task { @MainActor in
                self?.handlePetDragEnded(windowOrigin: origin)
            }
        }

        let window = PetWindow(renderView: renderView)
        petWindow = window
        window.orderFrontRegardless()
    }

    private func applyRuntimePositionAndMode() {
        guard let runtimeController else { return }

        updatePublishedState()
        petWindow?.setFrameOrigin(runtimeController.currentPosition)
        petWindow?.renderView.runtimeMode = runtimeController.currentMode
    }

    private func updatePublishedState() {
        guard let runtimeController else { return }
        currentPet = runtimeController.currentPet
        currentScale = runtimeController.currentScale
    }

    private func updatePetMode(_ mode: PetRuntimeMode) {
        guard let runtimeController else { return }
        runtimeController.overrideMode(mode)
        petWindow?.renderView.runtimeMode = mode
    }

    private func startOutsideClickMonitoring() {
        guard let petWindow, let panelWindow else { return }
        outsideClickMonitor?.stop()
        outsideClickMonitor = OutsideClickMonitor(
            petWindow: petWindow,
            panelWindow: panelWindow
        ) { [weak self] in
            Task { @MainActor in
                self?.hideTrelloAndRestorePet()
            }
        }
        outsideClickMonitor?.start()
    }

    private func handlePanelWindowClosed() {
        outsideClickMonitor?.stop()
        outsideClickMonitor = nil
        panelWindow = nil
        restorePetAfterTrelloClose()
    }

    private func restorePetAfterTrelloClose() {
        guard let runtimeController else { return }

        if let trelloReturnState {
            runtimeController.moveDraggedPet(to: trelloReturnState.position)
            runtimeController.overrideMode(trelloReturnState.mode)
            self.trelloReturnState = nil
            applyRuntimePositionAndMode()
            return
        }

        resetPetPosition()
    }

    var currentPetPositionForTesting: CGPoint {
        runtimeController?.currentPosition ?? .zero
    }

    var currentPetModeForTesting: PetRuntimeMode {
        runtimeController?.currentMode ?? .climbRight
    }

    func simulatePanelWindowClosedForTesting() {
        handlePanelWindowClosed()
    }

    var pluginsForTesting: [PluginConfiguration] {
        plugins
    }

    var selectedPluginForTesting: PluginConfiguration? {
        plugins.first(where: { $0.id == selectedPluginID })
    }

    var selectedPlugin: PluginConfiguration? {
        plugins.first(where: { $0.id == selectedPluginID })
    }

    var visiblePlugins: [PluginConfiguration] {
        plugins.filter(\.isEnabled)
    }

    var selectedPanelPlugin: PluginConfiguration? {
        visiblePlugins.first(where: { $0.id == selectedPanelPluginID })
    }

    var pluginStoreForTesting: PluginStore {
        pluginStore
    }

    func preparePluginPanelForTesting() {
        preparePluginPanelSelection()
    }

    var selectedPanelPluginForTesting: PluginConfiguration? {
        selectedPanelPlugin
    }

    var isPluginPanelEmptyForTesting: Bool {
        selectedPanelPlugin == nil
    }

    private func enterAgentMode() {
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    private func enterSettingsMode() {
        NSApplication.shared.setActivationPolicy(.regular)
    }

    private func configureMainMenu() {
        let mainMenu = NSMenu()

        let appItem = NSMenuItem(title: AppConstants.appName, action: nil, keyEquivalent: "")
        let appMenu = NSMenu(title: AppConstants.appName)
        appMenu.addItem(
            withTitle: "退出 \(AppConstants.appName)",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        appItem.submenu = appMenu
        mainMenu.addItem(appItem)

        let editItem = NSMenuItem(title: "编辑", action: nil, keyEquivalent: "")
        let editMenu = NSMenu(title: "编辑")
        editMenu.autoenablesItems = true
        editMenu.addItem(withTitle: "撤销", action: NSSelectorFromString("undo:"), keyEquivalent: "z")
        editMenu.addItem(withTitle: "重做", action: NSSelectorFromString("redo:"), keyEquivalent: "Z")
        editMenu.addItem(.separator())
        editMenu.addItem(withTitle: "剪切", action: NSSelectorFromString("cut:"), keyEquivalent: "x")
        editMenu.addItem(withTitle: "复制", action: NSSelectorFromString("copy:"), keyEquivalent: "c")
        editMenu.addItem(withTitle: "粘贴", action: NSSelectorFromString("paste:"), keyEquivalent: "v")
        editMenu.addItem(withTitle: "全选", action: NSSelectorFromString("selectAll:"), keyEquivalent: "a")
        editItem.submenu = editMenu
        mainMenu.addItem(editItem)
        NSApplication.shared.servicesMenu = editMenu

        let windowItem = NSMenuItem(title: "窗口", action: nil, keyEquivalent: "")
        let windowMenu = NSMenu(title: "窗口")
        let closeItem = NSMenuItem(
            title: "关闭",
            action: #selector(handleCloseMenuItem),
            keyEquivalent: "w"
        )
        closeItem.keyEquivalentModifierMask = [.command]
        closeItem.target = self
        windowMenu.addItem(closeItem)
        windowItem.submenu = windowMenu
        mainMenu.addItem(windowItem)
        NSApplication.shared.windowsMenu = windowMenu

        NSApplication.shared.mainMenu = mainMenu
    }

    @objc
    private func handleCloseMenuItem() {
        performWindowClose()
    }

    private func persistPlugins(selecting pluginID: UUID?) {
        do {
            try pluginStore.savePlugins(plugins)
            plugins = try pluginStore.loadPlugins()
            if let pluginID, plugins.contains(where: { $0.id == pluginID }) {
                selectedPluginID = pluginID
            } else {
                selectedPluginID = plugins.first?.id
            }
            preparePluginPanelSelection()
        } catch {
            assertionFailure("Failed to persist plugins: \(error)")
        }
    }

    private func preparePluginPanelSelection() {
        let visiblePluginIDs = Set(visiblePlugins.map(\.id))
        if let selectedPanelPluginID, visiblePluginIDs.contains(selectedPanelPluginID) {
            return
        }

        selectedPanelPluginID = visiblePlugins.first?.id
    }
}
