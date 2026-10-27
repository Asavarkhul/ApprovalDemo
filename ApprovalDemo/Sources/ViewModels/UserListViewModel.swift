import SwiftUI

@MainActor // Ensures observed properties are updated on the main thread
@Observable
final class UserListViewModel {
    
    // Dependency
    private let repository: UserListRepositoryType
    
    // Observed state
    var users: [User] = []
    var isLoading: Bool = false
    var error: Error?

    // Inject the repository; default to a new `UserListRepository()`
    init(repository: UserListRepositoryType = UserListRepository()) {
        self.repository = repository
    }
    
    func fetchUsers() async {
        isLoading = true
        error = nil
        do {
            let response = try await repository.getUserList()
            
            // Map API model to domain model
            let domainUsers = response.results.map { userResponse in
                User(
                    fullName: "\(userResponse.name.first) \(userResponse.name.last)",
                    thumbnailURL: userResponse.picture.thumbnail
                )
            }
            
            self.users = domainUsers
        } catch {
            self.error = error
        }
        isLoading = false
    }
}
