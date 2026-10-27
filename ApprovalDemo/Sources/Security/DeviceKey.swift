import Foundation

enum KeyMode: Sendable {
    case secureEnclave
    case simulator
}

enum KeyError: Error {
    case missing
    case accessControl
    case keychain(OSStatus)
}

// Device-bound signing key. Methods are nonisolated async,
// so signing runs off the main actor (access-controlled keys may block it).
protocol DeviceKey: Sendable {
    var mode: KeyMode { get }
    func create() async throws -> Data
    func sign(_ payload: Data) async throws -> Data
    func delete() throws
}

// The simulator rejects biometry-bound Secure Enclave keys (error -1020).
func makeDeviceKey() -> any DeviceKey {
    #if targetEnvironment(simulator)
    return SimulatorKey()
    #else
    return SecureEnclaveKey()
    #endif
}
