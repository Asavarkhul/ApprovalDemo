import SwiftUI

@MainActor
@Observable
final class ApprovalViewModel {

    // A signed response as it travelled to the server, kept to demonstrate a replay.
    private struct SignedResponse {
        let requestID: UUID
        let deviceID: UUID
        let signature: Data
    }

    // Dependencies
    private let server: any ApprovalServerType
    private let key: any DeviceKey

    // Observed state
    private(set) var deviceID: UUID?
    private(set) var request: ApprovalRequest?
    private(set) var message: String?
    private(set) var log: [AuditEntry] = []
    private(set) var isWorking = false
    private var lastResponse: SignedResponse?

    var mode: KeyMode { key.mode }
    var canReplay: Bool { lastResponse != nil }

    init(server: any ApprovalServerType = ApprovalServer(), key: any DeviceKey = makeDeviceKey()) {
        self.server = server
        self.key = key
    }

    func enable() async {
        isWorking = true
        defer { isWorking = false }

        do {
            let publicKey = try await key.create()
            deviceID = try await server.enroll(publicKey: publicKey)
            message = "Face ID approval enabled"
        } catch {
            message = "Enable failed: \(error.localizedDescription)"
        }
        await refreshLog()
    }

    func simulate() async {
        request = await server.requestSignIn(context: "Sign-in attempt, Chrome, Paris")
        message = nil
        await refreshLog()
    }

    func approve() async {
        guard let request, let deviceID else {
            return
        }

        isWorking = true
        defer { isWorking = false }

        do {
            // Face ID happens here; on failure nothing reaches the server.
            let payload = try ApprovalPayload(request: request, deviceID: deviceID).encoded()
            let signature = try await key.sign(payload)
            lastResponse = SignedResponse(requestID: request.id, deviceID: deviceID, signature: signature)
            try await server.approve(request.id, deviceID: deviceID, signature: signature)
            self.request = nil
            message = "Approved"
        } catch {
            message = "Not approved: \(error.localizedDescription)"
        }
        await refreshLog()
    }

    // Plays the attacker: sends the last signed response again, unchanged.
    func replay() async {
        guard let lastResponse else {
            return
        }

        do {
            try await server.approve(lastResponse.requestID, deviceID: lastResponse.deviceID, signature: lastResponse.signature)
            message = "Replay accepted"
        } catch {
            message = "Replay rejected: \(error.localizedDescription)"
        }
        await refreshLog()
    }

    func deny() async {
        guard let request else {
            return
        }

        try? await server.deny(request.id)
        self.request = nil
        message = "Denied"
        await refreshLog()
    }

    func disable() async {
        guard let deviceID else {
            return
        }

        await server.revoke(deviceID)
        try? key.delete()
        self.deviceID = nil
        request = nil
        message = "Face ID approval disabled"
        await refreshLog()
    }

    private func refreshLog() async {
        log = await server.auditLog()
    }
}
