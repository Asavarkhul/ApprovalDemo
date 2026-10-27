import Testing
import Foundation
@testable import ApprovalDemo

@MainActor
struct UserListViewModelTests {
    
    @Test
    func testFetchUsersSuccess() async {
        // GIVEN: A mock repo that won’t fail
        let mockRepository = MockUserListRepository(outcome: .success)
        
        // Initialize the view model on the main actor
        let viewModel = UserListViewModel(repository: mockRepository)
        
        // The view model starts with default states
        #expect(viewModel.users.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
        
        // WHEN: We fetch users
        await viewModel.fetchUsers()
        
        // THEN: The published properties should update
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
        
        // The mock returns 2 items
        #expect(viewModel.users.count == 2)
        
        let firstUser = viewModel.users[0]
        #expect(firstUser.fullName == "John Doe")
        
        let secondUser = viewModel.users[1]
        #expect(secondUser.fullName == "Jane Smith")
    }
    
    @Test
    func testFetchUsersFailure() async {
        // GIVEN: A mock repo that fails
        let mockRepository = MockUserListRepository(outcome: .failure)
        
        let viewModel = UserListViewModel(repository: mockRepository)
        
        // WHEN: We fetch users
        await viewModel.fetchUsers()
        
        // THEN: We expect an error
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error != nil)
        
        // And the users array remains empty
        #expect(viewModel.users.isEmpty)
    }
}
