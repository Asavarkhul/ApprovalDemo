import Foundation

// Exact bytes the device signs and the server rebuilds from its own data.
// Sorted keys make the encoding deterministic on both sides.
struct ApprovalPayload: Codable {
    let requestID: UUID
    let nonce: Data
    let context: String
    let deviceID: UUID

    init(request: ApprovalRequest, deviceID: UUID) {
        self.requestID = request.id
        self.nonce = request.nonce
        self.context = request.context
        self.deviceID = deviceID
    }

    func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return try encoder.encode(self)
    }
}
