import CryptoKit
import Testing
import Foundation

@testable import ApprovalDemo

struct ApprovalServerTests {

    private let context = "Sign-in attempt, Chrome, Paris"

    @Test("AC-1: enrollment stores the public key and activates the device")
    func ac1_enrollActivatesDevice() async throws {
        // GIVEN: a server and a device key
        let server = ApprovalServer()
        let key = P256.Signing.PrivateKey()

        // WHEN: the device enrolls, then approves a request
        let deviceID = try await server.enroll(publicKey: key.publicKey.derRepresentation)
        let request = await server.requestSignIn(context: context)
        try await server.approve(request.id, deviceID: deviceID, signature: sign(request, deviceID, key))

        // THEN: the enrolled key is accepted
        #expect(await server.request(request.id)?.status == .approved)
    }

    @Test("AC-2: a valid signature approves the request")
    func ac2_validSignatureApproves() async throws {
        let (server, key, deviceID) = try await makeEnrolled()
        let request = await server.requestSignIn(context: context)

        try await server.approve(request.id, deviceID: deviceID, signature: sign(request, deviceID, key))

        #expect(await server.request(request.id)?.status == .approved)
    }

    @Test("AC-3: deny marks the request denied without a signature")
    func ac3_denyMarksDenied() async throws {
        let (server, _, _) = try await makeEnrolled()
        let request = await server.requestSignIn(context: context)

        try await server.deny(request.id)

        #expect(await server.request(request.id)?.status == .denied)
    }

    @Test("AC-4: a replayed response is rejected")
    func ac4_replayRejected() async throws {
        let (server, key, deviceID) = try await makeEnrolled()
        let request = await server.requestSignIn(context: context)
        let signature = try sign(request, deviceID, key)
        try await server.approve(request.id, deviceID: deviceID, signature: signature)

        await #expect(throws: ApprovalError.alreadyUsed) {
            try await server.approve(request.id, deviceID: deviceID, signature: signature)
        }
    }

    @Test("AC-5: a response after expiry is rejected")
    func ac5_expiredRejected() async throws {
        let clock = TestClock()
        let (server, key, deviceID) = try await makeEnrolled(clock: clock)
        let request = await server.requestSignIn(context: context)

        clock.advance(by: ApprovalServer.validity + 1)

        await #expect(throws: ApprovalError.expired) {
            try await server.approve(request.id, deviceID: deviceID, signature: sign(request, deviceID, key))
        }
    }

    @Test("AC-6: a signature over altered text is rejected")
    func ac6_alteredTextRejected() async throws {
        let (server, key, deviceID) = try await makeEnrolled()
        let request = await server.requestSignIn(context: context)
        let altered = ApprovalRequest(
            id: request.id,
            nonce: request.nonce,
            context: "Sign-in attempt, Firefox, Lyon",
            expiresAt: request.expiresAt,
            status: .pending
        )

        await #expect(throws: ApprovalError.invalidSignature) {
            try await server.approve(request.id, deviceID: deviceID, signature: sign(altered, deviceID, key))
        }
    }

    @Test("AC-7: a signature from an unenrolled key is rejected")
    func ac7_forgedSignatureRejected() async throws {
        let (server, _, deviceID) = try await makeEnrolled()
        let request = await server.requestSignIn(context: context)
        let attacker = P256.Signing.PrivateKey()

        await #expect(throws: ApprovalError.invalidSignature) {
            try await server.approve(request.id, deviceID: deviceID, signature: sign(request, deviceID, attacker))
        }
    }

    @Test("AC-8: a revoked device is rejected")
    func ac8_revokedDeviceRejected() async throws {
        let (server, key, deviceID) = try await makeEnrolled()
        let request = await server.requestSignIn(context: context)
        await server.revoke(deviceID)

        await #expect(throws: ApprovalError.deviceRevoked) {
            try await server.approve(request.id, deviceID: deviceID, signature: sign(request, deviceID, key))
        }
    }

    @Test("The audit log records each verified approval and each rejection")
    func auditLogRecordsOutcomes() async throws {
        // GIVEN: an approved request
        let (server, key, deviceID) = try await makeEnrolled()
        let request = await server.requestSignIn(context: context)
        let signature = try sign(request, deviceID, key)
        try await server.approve(request.id, deviceID: deviceID, signature: signature)

        // WHEN: the same response is replayed
        try? await server.approve(request.id, deviceID: deviceID, signature: signature)

        // THEN: the log ends with the approval, then the rejection and its reason
        let outcomes = await server.auditLog().suffix(2).map(\.outcome)
        #expect(outcomes == [.success, .failure])
        #expect(await server.auditLog().last?.text == "Rejected: \(ApprovalError.alreadyUsed.localizedDescription)")
    }

    @Test("Rejection reasons read as sentences")
    func rejectionReasonsAreReadable() {
        #expect(ApprovalError.expired.localizedDescription == "This request expired.")
        #expect(ApprovalError.alreadyUsed.localizedDescription == "This request was already answered.")
    }

    // MARK: - Helpers

    private func makeEnrolled(
        clock: TestClock = TestClock()
    ) async throws -> (ApprovalServer, P256.Signing.PrivateKey, UUID) {
        let server = ApprovalServer(now: { clock.now() })
        let key = P256.Signing.PrivateKey()
        let deviceID = try await server.enroll(publicKey: key.publicKey.derRepresentation)
        return (server, key, deviceID)
    }

    private func sign(
        _ request: ApprovalRequest,
        _ deviceID: UUID,
        _ key: P256.Signing.PrivateKey
    ) throws -> Data {
        let payload = try ApprovalPayload(request: request, deviceID: deviceID).encoded()
        return try key.signature(for: payload).derRepresentation
    }
}
