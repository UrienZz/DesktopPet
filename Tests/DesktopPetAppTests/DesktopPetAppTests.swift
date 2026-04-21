import Testing
@testable import DesktopPetApp

@MainActor
@Test
func appCoordinatorStartsWithoutThrowing() async throws {
    let coordinator = AppCoordinator()
    coordinator.start()
}
