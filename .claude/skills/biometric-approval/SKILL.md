---
name: biometric-approval
description: >
  Face ID / Touch ID approval of sensitive actions with a Secure Enclave key
  and server-side signature verification. Use when adding biometric
  confirmation, out-of-band approval, 2FA "approve in the app", or anything
  touching LAContext, SecureEnclave, or SecAccessControl, even when the
  request only says "ask for Face ID".
---

# Biometric Approval

## Goal

A biometric check MUST produce a proof the server can verify, never a boolean the app forwards. Face ID unlocks a Secure Enclave key; the key signs the exact operation the user saw; the server verifies the signature with the public key it stored at enrollment.

## IMPORTANT

1. Never trust an `LAContext` boolean. `evaluatePolicy` returning `true` is a local fact that a patched binary can fake. Gate a signature, not a branch.
2. Sign the exact text shown to the user. If the server shows "Delete server X", the signature covers "Delete server X". Changing one character MUST invalidate it.
3. The server rebuilds the payload from its own data. It never verifies a payload sent by the client.
4. Sign off the main actor. Unlocking an access-controlled key can block the calling thread: keep `sign(_:)` a nonisolated `async` method.
5. Every request carries a nonce and an expiry, and is single use.

## Protocol in this repository

| Step | File |
|---|---|
| Key creation and signing (iPhone) | `ApprovalDemo/Sources/Security/SecureEnclaveKey.swift` |
| Simulator fallback | `ApprovalDemo/Sources/Security/SimulatorKey.swift` |
| Key abstraction and selection | `ApprovalDemo/Sources/Security/DeviceKey.swift` |
| Encrypted key blob storage | `ApprovalDemo/Sources/Security/KeyStore.swift` |
| Signed payload | `ApprovalDemo/Sources/Models/ApprovalPayload.swift` |
| Server checks | `ApprovalDemo/Sources/Server/ApprovalServer.swift` |
| UI flow | `ApprovalDemo/Sources/ViewModels/ApprovalViewModel.swift` |
| Attack tests | `ApprovalDemoTests/ApprovalServerTests.swift` |

## Use / Not

| Use | Not |
|---|---|
| Confirming a sensitive action (delete, pay, change a contact) | Unlocking the app's own UI: `LAContext` alone is enough there |
| Approving a sign-in from another device | Phishing-resistant sign-in: use passkeys |
| Binding an approval to one physical device | Syncing a credential across devices: use passkeys |

## References

- Payload format, order of server checks, test per attack: `references/protocol.md`
- Simulator limits and the fallback key: `references/simulator.md`
- Push, number matching, authenticated enrollment, App Attest: `references/hardening.md`
