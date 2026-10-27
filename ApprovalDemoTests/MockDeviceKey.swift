import CryptoKit
import Foundation
import LocalAuthentication

@testable import ApprovalDemo

final class MockDeviceKey: DeviceKey {
    enum Outcome {
        case success
        case failure
    }

    let mode = KeyMode.simulator
    private let outcome: Outcome
    private let rawKey = P256.Signing.PrivateKey().rawRepresentation

    init(outcome: Outcome) {
        self.outcome = outcome
    }

    func create() async throws -> Data {
        try P256.Signing.PrivateKey(rawRepresentation: rawKey).publicKey.derRepresentation
    }

    func sign(_ payload: Data) async throws -> Data {
        if outcome == .failure {
            throw LAError(.userCancel)
        }

        return try P256.Signing.PrivateKey(rawRepresentation: rawKey).signature(for: payload).derRepresentation
    }

    func delete() throws {}
}
