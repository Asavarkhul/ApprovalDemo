import SwiftUI

@MainActor
@Observable
final class ApprovalViewModel {

    // Dependencies
    private let server: any ApprovalServerType
    private let key: any DeviceKey

    // Observed state
    private(set) var deviceID: UUID?
    private(set) var request: ApprovalRequest?
    private(set) var message: String?

    var mode: KeyMode { key.mode }

    init(server: any ApprovalServerType = ApprovalServer(), key: any DeviceKey = makeDeviceKey()) {
        self.server = server
        self.key = key
    }

    func enable() async {
        do {
            let publicKey = try await key.create()
            deviceID = try await server.enroll(publicKey: publicKey)
            message = "Face ID approval enabled"
        } catch {
            message = "Enable failed: \(error.localizedDescription)"
        }
    }

    func simulate() async {
        request = await server.requestSignIn(context: "Sign-in attempt, Chrome, Paris")
        message = nil
    }

    func approve() async {
        guard let request, let deviceID else {
            return
        }

        do {
            // Face ID happens here; on failure nothing reaches the server.
            let payload = try ApprovalPayload(request: request, deviceID: deviceID).encoded()
            let signature = try await key.sign(payload)
            try await server.approve(request.id, deviceID: deviceID, signature: signature)
            self.request = nil
            message = "Approved"
        } catch {
            message = "Not approved: \(error.localizedDescription)"
        }
    }

    func deny() async {
        guard let request else {
            return
        }

        try? await server.deny(request.id)
        self.request = nil
        message = "Denied"
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
    }
}
