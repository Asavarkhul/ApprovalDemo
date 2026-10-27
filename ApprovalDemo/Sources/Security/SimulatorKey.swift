import CryptoKit
import Foundation
import LocalAuthentication

// Same protocol, weaker guarantee: the key is not bound to Face ID,
// so biometry is checked explicitly before signing.
struct SimulatorKey: DeviceKey {
    let mode = KeyMode.simulator
    private let store = KeyStore()

    func create() async throws -> Data {
        let key = try SecureEnclave.P256.Signing.PrivateKey()
        try store.save(key.dataRepresentation)
        return key.publicKey.derRepresentation
    }

    func sign(_ payload: Data) async throws -> Data {
        guard let blob = try store.load() else {
            throw KeyError.missing
        }

        _ = try await LAContext().evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Approve the request"
        )
        let key = try SecureEnclave.P256.Signing.PrivateKey(dataRepresentation: blob)
        return try key.signature(for: payload).derRepresentation
    }

    func delete() throws {
        try store.delete()
    }
}
