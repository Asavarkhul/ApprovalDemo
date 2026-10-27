# Simulator

The iOS simulator refuses to create a Secure Enclave key with `.biometryCurrentSet`, `.biometryAny` or `.userPresence`: error `com.apple.LocalAuthentication -1020`. It accepts a Secure Enclave key without access control.

`makeDeviceKey()` picks the implementation at compile time:

| | `SecureEnclaveKey` (device) | `SimulatorKey` (simulator) |
|---|---|---|
| Access control | `[.privateKeyUsage, .biometryCurrentSet]` | None |
| Face ID | Enforced by the Secure Enclave | `evaluatePolicy` before signing |
| Face re-enrolled | Key invalidated | No effect |

The server and the payload are identical in both modes. The weaker guarantee MUST stay visible: the Security tab shows a banner when `mode == .simulator`.

To drive Face ID in the simulator: Features > Face ID > Enrolled, then Matching Face or Non-matching Face when the prompt appears.
