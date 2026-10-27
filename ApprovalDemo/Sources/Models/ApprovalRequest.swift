import Foundation

struct ApprovalRequest: Identifiable, Equatable, Sendable {
    enum Status: Sendable {
        case pending
        case approved
        case denied
    }

    let id: UUID
    let nonce: Data
    let context: String
    let expiresAt: Date
    var status: Status
}
