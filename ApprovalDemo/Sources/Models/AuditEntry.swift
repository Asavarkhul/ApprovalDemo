import Foundation

// One line of the server's audit log, shown in the Security tab.
struct AuditEntry: Identifiable, Equatable, Sendable {
    enum Outcome: Sendable {
        case info
        case success
        case failure
    }

    let id = UUID()
    let date: Date
    let text: String
    let outcome: Outcome
}
