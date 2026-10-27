---
name: ios-unit-testing
description: >
  Unit testing conventions for this SwiftUI codebase with Swift Testing:
  struct suites, GIVEN / WHEN / THEN, mocks driven by an Outcome enum, injected
  clocks, software keys for cryptography, one test per attack. Use when writing
  or fixing tests, adding a mock, testing time-dependent or security code, even
  when the request only says "add a test".
---

# iOS Unit Testing

## Goal

Tests are fast, deterministic, and each one fails for exactly one reason.

## Rules

1. Use Swift Testing (`import Testing`, `@Test`, `#expect`). Suites are `struct`; add `@MainActor` when they drive a view model. Example: `ApprovalDemoTests/UserListViewModelTests.swift`.
2. Mark the steps with `// GIVEN`, `// WHEN`, `// THEN`.
3. A mock takes an `Outcome` enum, never a boolean. Example: `MockUserListRepository(outcome: .failure)`, `MockDeviceKey(outcome: .failure)`.
4. Time is injected. Example: `ApprovalServer(now: { clock.now() })` with `ApprovalDemoTests/TestClock.swift`, then `clock.advance(by:)`. Tests MUST NOT sleep.
5. Cryptography uses software keys (`P256.Signing.PrivateKey`): deterministic, independent of the Secure Enclave and the simulator.
6. Expected errors use `#expect(throws:)` with the exact case. Example: `await #expect(throws: ApprovalError.expired) { ... }`.
7. Unwrap with `try #require`, never `try!`: a trap kills every test in the process.
8. Each security check has a test that fails when the check is removed. Verify it once by disabling the check and watching the test fail. Example: `ApprovalDemoTests/ApprovalServerTests.swift`.
9. When a test name comes from an acceptance criterion, keep its id: `ac4_replayRejected`.

## Example

```swift
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
```

## Running

```bash
xcodebuild test -project ApprovalDemo.xcodeproj -scheme ApprovalDemo \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

Count failures with `grep "Test case '.*' failed"`: the final summary alone can hide a failing suite.

## Use / Not

| Use | Not |
|---|---|
| Logic in view models, repositories, servers | Pixel layout: check it in a preview or on device |
| Security rules, one test per attack | Apple frameworks themselves |
