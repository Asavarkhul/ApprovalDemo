# ApprovalDemo

A SwiftUI demo of Face ID approval backed by a Secure Enclave signature.

## What it shows

A sign-in attempt waits for approval on the phone. The user reads the request, approves it with Face ID, and the server accepts it only if the signature checks out. Face ID does not return a boolean that the app forwards: it unlocks a private key that never leaves the Secure Enclave, and that key signs the exact request the user saw.

The server is simulated inside the app (`ApprovalServer`, an `actor`). A real backend would implement the same `ApprovalServerType` protocol; the protocol itself does not change.

## Run

1. Open `ApprovalDemo.xcodeproj`.
2. In the simulator, enable Features > Face ID > Enrolled.
3. Cmd+R, open the Security tab, then Enable, Simulate sign-in attempt, Approve.
4. When the Face ID prompt appears, choose Features > Face ID > Matching Face (or Non-matching Face to see a refusal).

Cmd+U runs the tests. No server, account or setting is required.

## Run on an iPhone

1. Create `Config/Signing.local.xcconfig` (ignored by git) containing `DEVELOPMENT_TEAM = <your team ID>`.
2. Select your iPhone and run.

A free personal team is enough: Face ID, Keychain and the Secure Enclave are not paid capabilities. Profiles from a free team expire after 7 days.

## How it works

```
Sign-in page           App              Secure Enclave         Server
      |                 |                      |                  |
      |                 |== ENROLLMENT ===========================|
      |                 |-- create P-256 key ->|                  |
      |                 | biometry-bound       |                  |
      |                 |-- public key (DER) -------------------->| stores the device
      |                 |                      |                  |
      |== APPROVAL ===============================================|
      |-- sign-in attempt --------------------------------------->| creates the request:
      |                 |<-- pending request ---------------------|   id, nonce, text,
      |                 | shows the text       |                  |   expiry (120 s)
      |                 |-- sign(payload) ---->|                  |
      |                 |                      | Face ID          |
      |                 |<-- signature --------|                  |
      |                 |-- signed response --------------------->| checks: pending,
      |<-- approved / rejected -----------------------------------|   not expired, device
                                                                      active, signature
```

The signed payload (`ApprovalPayload`) holds the request id, the nonce, the text shown and the device id, encoded as JSON with sorted keys. The server never trusts the payload sent by the client: it rebuilds it from its own data, then verifies the signature with the public key stored at enrollment.

Deny sends no signature: a forged refusal grants no access.

## Simulator vs device

| | iPhone | Simulator |
|---|---|---|
| Key | Secure Enclave, `[.privateKeyUsage, .biometryCurrentSet]` | Secure Enclave, no access control |
| Face ID | Required by the key itself | Checked by `evaluatePolicy` before signing |
| Re-enrolling a face | Invalidates the key | No effect |

The simulator refuses biometry-bound Secure Enclave keys (error -1020). `makeDeviceKey()` picks the right implementation at compile time, and the Security tab shows a banner in simulator mode. The protocol and the server are identical in both modes.

## Attacks and tests

| Attack | Test |
|---|---|
| Replay of an approved response | `ac4_replayRejected` |
| Late approval | `ac5_expiredRejected` |
| Text changed after display | `ac6_alteredTextRejected` |
| Forged signature | `ac7_forgedSignatureRejected` |
| Lost or revoked device | `ac8_revokedDeviceRejected` |
| Face ID failure | `ac9_faceIDFailureSendsNothing` |

Each rejection is logged with its reason (`os.Logger`, subsystem `com.oc.ApprovalDemo`, category `approval`).

## From demo to production

- Push: a real request reaches the phone through APNs, which needs a paid developer account. It is the only missing piece between this demo and a working flow.
- Number matching: the sign-in page shows a number that the user types in the app. NIST SP 800-63B-4 requires it for out-of-band approval, and CISA recommends it against push bombing.
- Authenticated enrollment: the demo accepts any public key. A real enrollment binds the key to an account already authenticated.
- App Attest: proves the request comes from the genuine app.
- Passkeys for sign-in, approval for actions: passkeys resist phishing but cannot sign the details of an operation. This approval flow fits sensitive actions (delete a server, change a contact, pay).

Out-of-band approval is not phishing-resistant: a user can approve a sign-in started by an attacker. Number matching reduces that risk without removing it.

## Claude Code skills

`.claude/skills/` holds eleven skills, loaded automatically by Claude Code in this repository.

- `biometric-approval`: Face ID approval with a Secure Enclave key and server-side verification.
- `ios-architecture`, `ios-networking`, `ios-unit-testing`: conventions of this codebase, each rule illustrated by a file of the repository.
- `ace-research`, `ace-grill`, `ace-plan`, `ace-implement`: a four-step workflow (research, decisions, plan, implementation), prefixed `ace-` to avoid clashing with built-in commands.
- `swiftui-expert-skill`, `swift-concurrency`, `swift-testing-expert`: third-party skills by Antoine van der Lee, MIT licensed, pinned to a commit.

`scripts/update-skills.sh` downloads the third-party skills at the commits it pins, with their license. Bump a commit, rerun the script and review the diff.
