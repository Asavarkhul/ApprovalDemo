import CryptoKit
import Foundation
import LocalAuthentication

// Face ID unlocks the key itself: no signature without a successful match.
struct SecureEnclaveKey: DeviceKey {
    let mode = KeyMode.secureEnclave
    private let store = KeyStore()

    func create() async throws -> Data {
        guard let access = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [.privateKeyUsage, .biometryCurrentSet],
            nil
        ) else {
            throw KeyError.accessControl
        }

        let key = try SecureEnclave.P256.Signing.PrivateKey(accessControl: access)
        try store.save(key.dataRepresentation)
        return key.publicKey.derRepresentation
    }

    func sign(_ payload: Data) async throws -> Data {
        guard let blob = try store.load() else {
            throw KeyError.missing
        }

        let context = LAContext()
        context.localizedReason = "Approve the request"
        let key = try SecureEnclave.P256.Signing.PrivateKey(
            dataRepresentation: blob,
            authenticationContext: context
        )
        return try key.signature(for: payload).derRepresentation
    }

    func delete() throws {
        try store.delete()
    }
}
