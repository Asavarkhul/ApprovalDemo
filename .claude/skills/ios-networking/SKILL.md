---
name: ios-networking
description: >
  Networking conventions for this SwiftUI codebase: request execution injected
  as a Sendable closure, URLRequest built from a URL, method and parameters,
  Codable responses mapped to domain models in the view model. Use when calling
  an API, adding an endpoint, decoding JSON, or testing network code without a
  network, even when the request only says "fetch data".
---

# iOS Networking

## Goal

Network code stays testable without a network and API types never leak into the UI.

## Rules

1. A repository receives the function that executes a request, as a `@Sendable` closure defaulting to `URLSession.shared.data(for:)`. Tests replace it. Example: `ApprovalDemo/Sources/Repositories/UserListRepository.swift`.
2. Requests are built with `URLRequest(url:method:parameters:)`, which encodes GET parameters as query items. Example: `ApprovalDemo/Sources/Repositories/URLRequest+Extensions.swift`.
3. HTTP methods come from the `HTTPMethod` enum, never from string literals.
4. Responses decode into `Codable` API types that mirror the JSON. Example: `ApprovalDemo/Sources/Models/UserListResponse.swift`.
5. The view model maps API types to domain models before exposing them. Example: `UserListViewModel.fetchUsers()` turns `UserResponse` into `User`.
6. Errors propagate with `throws`; the view model stores them for display. A repository MUST NOT swallow an error.

## Example

```swift
init(executedDataRequest: @escaping @Sendable (URLRequest) async throws -> (Data, URLResponse) = URLSession.shared.data(for:)) {
    self.executedDataRequest = executedDataRequest
}
```

In a test:

```swift
let repository = UserListRepository(executedDataRequest: { _ in
    throw URLError(.cannotConnectToHost)
})
```

## Use / Not

| Use | Not |
|---|---|
| A new endpoint or API | Local persistence (Keychain, files) |
| Decoding a JSON payload | A simulated backend: see `ApprovalServer` |
