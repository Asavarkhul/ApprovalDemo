import Foundation
@testable import ApprovalDemo

final class MockUserListRepository: UserListRepositoryType {
    var shouldFail: Bool = false

    func getUserList() async throws -> UserListResponse {
        if shouldFail {
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
