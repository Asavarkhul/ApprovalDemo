import CryptoKit
import Foundation
import os

// Stand-in for the real backend. A network client would implement the same protocol.
protocol ApprovalServerType: Sendable {
    func enroll(publicKey: Data) async throws -> UUID
    func revoke(_ deviceID: UUID) async
    func requestSignIn(context: String) async -> ApprovalRequest
    func approve(_ requestID: UUID, deviceID: UUID, signature: Data) async throws
    func deny(_ requestID: UUID) async throws
    func request(_ id: UUID) async -> ApprovalRequest?
}

actor ApprovalServer: ApprovalServerType {

    // MARK: - Properties

    static let validity: TimeInterval = 120

    private let now: @Sendable () -> Date
    private let logger = Logger(subsystem: "com.oc.ApprovalDemo", category: "approval")
    private var keys: [UUID: Data] = [:]
    private var revoked: Set<UUID> = []
    private var requests: [UUID: ApprovalRequest] = [:]

    // MARK: - Init

    init(now: @escaping @Sendable () -> Date = { Date() }) {
        self.now = now
    }

    // MARK: - ApprovalServerType

    func enroll(publicKey: Data) throws -> UUID {
        // Rejects malformed keys at enrollment rather than at first approval.
        _ = try P256.Signing.PublicKey(derRepresentation: publicKey)

        let deviceID = UUID()
        keys[deviceID] = publicKey
        return deviceID
    }

    func revoke(_ deviceID: UUID) {
        revoked.insert(deviceID)
    }

    func requestSignIn(context: String) -> ApprovalRequest {
        let nonce = SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) }
        let request = ApprovalRequest(
            id: UUID(),
            nonce: nonce,
            context: context,
            expiresAt: now().addingTimeInterval(Self.validity),
            status: .pending
        )
        requests[request.id] = request
        return request
    }

    func approve(_ requestID: UUID, deviceID: UUID, signature: Data) throws {
        guard var request = requests[requestID] else {
            throw reject(.unknownRequest)
        }
        guard request.status == .pending else {
            throw reject(.alreadyUsed)
        }
        guard now() < request.expiresAt else {
            throw reject(.expired)
        }
        guard !revoked.contains(deviceID) else {
            throw reject(.deviceRevoked)
        }
        guard let publicKey = keys[deviceID] else {
            throw reject(.unknownDevice)
        }

        // Rebuild what the user saw from server data, never from the client.
        let payload = try ApprovalPayload(request: request, deviceID: deviceID).encoded()
        guard Self.verify(signature, of: payload, with: publicKey) else {
            throw reject(.invalidSignature)
        }

        request.status = .approved
        requests[requestID] = request
    }

    func deny(_ requestID: UUID) throws {
        guard var request = requests[requestID], request.status == .pending else {
            throw reject(.unknownRequest)
        }

        request.status = .denied
        requests[requestID] = request
        logger.notice("Request \(requestID.uuidString, privacy: .public) denied")
    }

    func request(_ id: UUID) -> ApprovalRequest? {
        requests[id]
    }

    // MARK: - Private

    private func reject(_ error: ApprovalError) -> ApprovalError {
        logger.error("Rejected: \(String(describing: error), privacy: .public)")
        return error
    }

    private static func verify(_ signature: Data, of payload: Data, with publicKey: Data) -> Bool {
        guard
            let key = try? P256.Signing.PublicKey(derRepresentation: publicKey),
            let ecdsa = try? P256.Signing.ECDSASignature(derRepresentation: signature)
        else {
            return false
        }

        return key.isValidSignature(ecdsa, for: payload)
    }
}
