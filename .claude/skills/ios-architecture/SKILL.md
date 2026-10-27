---
name: ios-architecture
description: >
  Layering and dependency rules for this SwiftUI codebase: View, ViewModel,
  Repository or Server, injected protocols, actors for shared state, low-level
  APIs behind a small type. Use when adding a screen, a view model, a service,
  a data source, or when deciding where a piece of code belongs, even when the
  request only says "add a feature".
---

# iOS Architecture

## Goal

Every feature follows the same four layers, so a reader finds the code where they expect it and every layer can be tested alone.

```
View  ──>  ViewModel  ──>  Repository / Server  ──>  URLSession, Keychain, Secure Enclave
```

## Rules

1. A layer MUST talk only to the layer directly below it. A view MUST NOT call a repository, a view model MUST NOT call `URLSession` or `SecItem*`.
2. View models are `@MainActor @Observable final class`. Example: `ApprovalDemo/Sources/ViewModels/UserListViewModel.swift`, `ApprovalDemo/Sources/ViewModels/ApprovalViewModel.swift`.
3. Views own their view model with `@State`, and navigate with `NavigationStack`. Example: `ApprovalDemo/Sources/Views/ContentView.swift`.
4. Dependencies are protocols injected through `init`, with the production implementation as default value. Example: `init(server: any ApprovalServerType = ApprovalServer(), key: any DeviceKey = makeDeviceKey())`.
5. Protocols that cross concurrency domains inherit `Sendable`. Example: `UserListRepositoryType: Sendable`.
6. Shared mutable state lives in an `actor`. Example: `ApprovalDemo/Sources/Server/ApprovalServer.swift`.
7. Low-level APIs stay behind a small type with a domain vocabulary: `save`, `load`, `delete`. Example: `ApprovalDemo/Sources/Security/KeyStore.swift` wraps the Keychain.
8. Blocking or slow work runs off the main actor in nonisolated `async` methods. Example: `DeviceKey.sign(_:)`.
9. Small types that belong together MAY share a file. Example: `ApprovalDemo/Sources/Models/UserListResponse.swift`.

## Folders

| Folder | Content |
|---|---|
| `Sources/Views` | SwiftUI views |
| `Sources/ViewModels` | `@Observable` view models |
| `Sources/Models` | Value types, API responses, errors |
| `Sources/Repositories` | Network data sources |
| `Sources/Server` | Stand-ins for a backend |
| `Sources/Security` | Keys, Keychain, biometry |

## Use / Not

| Use | Not |
|---|---|
| A new screen with data | A pure layout change inside one view |
| A new data source or service | Renaming a local variable |
