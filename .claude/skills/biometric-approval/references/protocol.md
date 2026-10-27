# Protocol

## Payload

`ApprovalPayload` is the only thing signed. It holds:

| Field | Why |
|---|---|
| `requestID` | Binds the signature to one request |
| `nonce` | 256 random bits from the server, defeats precomputed signatures |
| `context` | The text shown to the user, so changing it breaks the signature |
| `deviceID` | Binds the signature to the enrolled device |

It is encoded as JSON with `.sortedKeys`: the device and the server produce the same bytes without a custom format. Concatenating strings without separators is ambiguous ("ab" + "c" equals "a" + "bc") and MUST NOT be used.

## Server checks

`ApprovalServer.approve` runs these checks in order and stops at the first failure:

1. The request exists (`unknownRequest`).
2. The request is still pending (`alreadyUsed`): single use, defeats replay.
3. The request has not expired (`expired`): 120 seconds, injected clock.
4. The device is not revoked (`deviceRevoked`).
5. The device is enrolled (`unknownDevice`).
6. The signature matches the payload rebuilt from server data (`invalidSignature`).

Each rejection is logged with its reason. Deny needs no signature: a forged refusal grants nothing.

## One test per attack

| Attack | Test |
|---|---|
| Replay | `ac4_replayRejected` |
| Late approval | `ac5_expiredRejected` |
| Altered text | `ac6_alteredTextRejected` |
| Forged signature | `ac7_forgedSignatureRejected` |
| Revoked device | `ac8_revokedDeviceRejected` |
| Face ID failure | `ac9_faceIDFailureSendsNothing` |

Tests sign with software keys (`P256.Signing.PrivateKey`): deterministic, no Secure Enclave needed. A new server check MUST come with a test that fails when the check is removed.
