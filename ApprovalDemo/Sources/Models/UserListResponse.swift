import Foundation

struct UserListResponse: Codable {
    let results: [UserResponse]
}

struct UserResponse: Codable {
    let name: UserName
    let picture: UserPicture
}

struct UserName: Codable {
    let title: String
    let first: String
    let last: String
}

struct UserPicture: Codable {
    let large: String
    let medium: String
    let thumbnail: String
}
