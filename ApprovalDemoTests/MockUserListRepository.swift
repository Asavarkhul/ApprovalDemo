import Foundation
@testable import ApprovalDemo

final class MockUserListRepository: UserListRepositoryType {
    enum Outcome {
        case success
        case failure
    }

    private let outcome: Outcome

    init(outcome: Outcome) {
        self.outcome = outcome
    }

    func getUserList() async throws -> UserListResponse {
        if outcome == .failure {
            throw URLError(.badServerResponse)
        }
        return UserListResponse(
            results: [
                UserResponse(
                    name: UserName(title: "Mr", first: "John", last: "Doe"),
                    picture: UserPicture(
                        large: "https://randomuser.me/api/portraits/men/1.jpg",
                        medium: "https://randomuser.me/api/portraits/med/men/1.jpg",
                        thumbnail: "https://randomuser.me/api/portraits/thumb/men/1.jpg"
                    )
                ),
                UserResponse(
                    name: UserName(title: "Ms", first: "Jane", last: "Smith"),
                    picture: UserPicture(
                        large: "https://randomuser.me/api/portraits/women/1.jpg",
                        medium: "https://randomuser.me/api/portraits/med/women/1.jpg",
                        thumbnail: "https://randomuser.me/api/portraits/thumb/women/1.jpg"
                    )
                )
            ]
        )
    }
}
