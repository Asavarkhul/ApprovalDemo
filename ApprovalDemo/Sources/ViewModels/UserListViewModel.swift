import SwiftUI
import Combine

@MainActor // Ensures published properties are updated on the main thread
final class UserListViewModel: ObservableObject {
    
    // Dependency
    private let repository: UserListRepositoryType
    
    // Published state
    @Published var users: [User] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?

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
