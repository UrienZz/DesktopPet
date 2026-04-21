import AppKit
import Foundation
import SwiftUI

@MainActor
final class AppCoordinator: NSObject, ObservableObject {
    @Published private(set) var availablePets: [PetDefinition] = []
    @Published private(set) var currentPet: PetDefinition?
    @Published var currentScale: Double = AppConstants.defaultPetScale
    @Published var previewStateName: String = ""
    @Published private(set) var isPetAnimationPaused = false

    private let catalogLoader = PetCatalogLoader()
    private let preferencesStore: AppPreferencesStore

    private var runtimeController: PetRuntimeController?
    private var menuBarController: MenuBarController?
    private var petWindow: PetWindow?
    private var panelWindow: PanelWindow?
    private var settingsWindowController: SettingsWindowController?
    private var outsideClickMonitor: OutsideClickMonitor?

    init(preferencesStore: AppPreferencesStore = AppPreferencesStore()) {
        self.preferencesStore = preferencesStore
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

    func showTrello() {
        guard let petWindow else { return }
        updatePetMode(.hovering)

        if let panelWindow {
            self.panelWindow = panelWindow
            panelWindow.show(anchoredTo: petWindow.frame)
            startOutsideClickMonitoring()
            return
        }

        let panelWindow = PanelWindow(rootView: TrelloPanelView()) { [weak self] in
            Task { @MainActor in
                self?.handlePanelWindowClosed()
            }
        }
        self.panelWindow = panelWindow
        panelWindow.show(anchoredTo: petWindow.frame)
        startOutsideClickMonitoring()
    }

    func hideTrelloAndResetPet() {
        panelWindow?.orderOut(nil)
        outsideClickMonitor?.stop()
        outsideClickMonitor = nil
        resetPetPosition()
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
            hideTrelloAndResetPet()
        } else {
            settingsWindowController?.close()
        }
    }

    private func createMenuBarController() {
        menuBarController = MenuBarController(
            onOpenSettings: { [weak self] in self?.openSettings() },
            onShowTrello: { [weak self] in self?.showTrello() },
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
                self?.showTrello()
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
                self?.hideTrelloAndResetPet()
            }
        }
        outsideClickMonitor?.start()
    }

    private func handlePanelWindowClosed() {
        outsideClickMonitor?.stop()
        outsideClickMonitor = nil
        panelWindow = nil
        resetPetPosition()
    }

    private func enterAgentMode() {
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    private func enterSettingsMode() {
        NSApplication.shared.setActivationPolicy(.regular)
    }

    private func configureMainMenu() {
        let mainMenu = NSMenu()

        let appItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(
            withTitle: "退出 \(AppConstants.appName)",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        appItem.submenu = appMenu
        mainMenu.addItem(appItem)

        let windowItem = NSMenuItem()
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

        NSApplication.shared.mainMenu = mainMenu
    }

    @objc
    private func handleCloseMenuItem() {
        performWindowClose()
    }
}
