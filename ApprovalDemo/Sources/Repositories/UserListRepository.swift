import Foundation

protocol UserListRepositoryType {
    func getUserList() async throws -> UserListResponse
}

final class UserListRepository: UserListRepositoryType {

    // MARK: - Properties

    private let executedDataRequest: (URLRequest) async throws -> (Data, URLResponse)

    // MARK: - Init

    init(executedDataRequest: @escaping (URLRequest) async throws -> (Data, URLResponse) = URLSession.shared.data(for:)) {
        self.executedDataRequest = executedDataRequest
    }

    // MARK: - UserListRepositoryType

    func getUserList() async throws -> UserListResponse {
        // Create url
        guard let url = URL(string: "https://randomuser.me/api/") else {
            throw URLError(.badURL)
        }

        // Create Request
        let request = try URLRequest(
            url: url,
            method: .GET,
            parameters: ["results": 10] // Hardcoded Limit to 10 results
        )

        // Execute Request
        let (data, _) = try await executedDataRequest(request)

        // Transform obtained data to Codable object
        let object = try JSONDecoder().decode(
            UserListResponse.self,
            from: data
        )

        // Return Codable Object
        return object
    }
}
