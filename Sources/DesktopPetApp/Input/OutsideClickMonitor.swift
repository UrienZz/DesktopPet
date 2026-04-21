import AppKit

@MainActor
final class OutsideClickMonitor {
    private weak var petWindow: PetWindow?
    private weak var panelWindow: NSWindow?
    private let onOutsideClick: () -> Void
    private var globalMonitor: Any?
    private var localMonitor: Any?

    init(petWindow: PetWindow, panelWindow: NSWindow, onOutsideClick: @escaping () -> Void) {
        self.petWindow = petWindow
        self.panelWindow = panelWindow
        self.onOutsideClick = onOutsideClick
    }

    func start() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            Task { @MainActor [weak self] in
                self?.handle(event: event)
            }
        }
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            Task { @MainActor [weak self] in
                self?.handle(event: event)
            }
            return event
        }
    }

    func stop() {
        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
        }
        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
        }
        globalMonitor = nil
        localMonitor = nil
    }

    private func handle(event: NSEvent) {
        let location = NSEvent.mouseLocation
        let isInsidePet = petWindow?.containsInteractiveScreenPoint(location) ?? false
        let isInsidePanel = panelWindow?.frame.contains(location) ?? false

        if !isInsidePet && !isInsidePanel {
            onOutsideClick()
        }
    }
}
