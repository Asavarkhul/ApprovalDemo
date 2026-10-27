# ApprovalDemo

SwiftUI app, iOS 18+, Swift 6 language mode. Two tabs: Users (random user list) and Security (Face ID approval).

## Build and test

```bash
xcodebuild test -project ApprovalDemo.xcodeproj -scheme ApprovalDemo \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

Zero warnings: a concurrency warning is a build failure. Under `xcodebuild`, count failures with `grep "Test case '.*' failed"`.

## Architecture

```
View  ──>  ViewModel (@MainActor @Observable)  ──>  Repository / Server (protocol)  ──>  URLSession / Keychain / Secure Enclave
```

- Each layer talks only to the layer directly below it.
- Dependencies are protocols injected through `init`, with a production default (`UserListRepositoryType`, `ApprovalServerType`, `DeviceKey`).
- Shared mutable state lives in an `actor` (`ApprovalServer`).
- Low-level APIs stay behind a small type (`KeyStore` for the Keychain, `DeviceKey` for the Secure Enclave).

## Rules

- Swift 6, `@Observable`, `NavigationStack`. No `ObservableObject`, no Combine.
- Braces on every `if`, even one line. Early return over nested conditions.
- Enums, not booleans, as parameters (`MockDeviceKey(outcome: .failure)`).
- Short function names (under 30 characters); test names describe the behavior.
- Signing and other Secure Enclave work runs off the main actor: nonisolated `async` methods.
- Tests use Swift Testing, suites are `struct`, steps are marked GIVEN / WHEN / THEN.
- Never `try!` in tests: `try #require` instead.

## Language

Everything versioned is in English: code, comments, UI strings, docs, skills, commit messages.

## Skills

Project skills live in `.claude/skills/`:

- `biometric-approval`: Face ID approval, Secure Enclave keys, server-side verification.
- `ios-architecture`: layers, injection, actors.
- `ios-networking`: injected request closure, `Codable`, domain mapping.
- `ios-unit-testing`: suites, mocks, injected clock, attack tests.
- `ace-research`, `ace-grill`, `ace-plan`, `ace-implement`: research, decisions, plan, implementation.
- `swiftui-expert-skill`, `swift-concurrency`, `swift-testing-expert`: third-party, updated by `scripts/update-skills.sh`.
