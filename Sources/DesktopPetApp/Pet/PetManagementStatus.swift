import Foundation

struct PetManagementStatus: Equatable, Sendable {
    enum Kind: Equatable, Sendable {
        case success
        case error
    }

    let kind: Kind
    let message: String
}
