import Testing
import Foundation

@testable import ApprovalDemo

class UserListRepositoryTests {

    @Test
    func testGetUserListSuccess() async {
        // GIVEN: A mock data request that returns valid JSON
        let mockRequest = makeMockDataRequest(data: mockJSON, statusCode: 200)
        
        // Initialize the repository with our mock
        let repository = UserListRepository(executedDataRequest: mockRequest)
        
        do {
            // WHEN: We call getUserList()
            let response = try await repository.getUserList()
            
            // THEN: We expect the response to parse 1 user named "John Doe"
            #expect(response.results.count == 1)
            
            let userResponse = response.results[0]
            #expect(userResponse.name.first == "John")
            #expect(userResponse.name.last == "Doe")
            #expect(userResponse.picture.thumbnail.contains("thumb/men/1.jpg"))
            
        } catch {
            // If it throws, the test should fail
            #expect(Bool(false), "Expected success but got error: \(error)")
        }
    }
    
    @Test
    func testGetUserListFailure() async {
        // GIVEN: A mock request that throws
        let mockRequest = makeFailingDataRequest()
        
        // Initialize the repository with our failing closure
        let repository = UserListRepository(executedDataRequest: mockRequest)
        
        do {
            // WHEN: We call getUserList()
            _ = try await repository.getUserList()
            
            // THEN: We do NOT expect to reach here
            #expect(Bool(false), "Expected an error, but got success.")
        } catch {
            // 1. Verify it's a URLError
            guard let urlError = error as? URLError else {
                #expect(Bool(false), "Expected URLError but got \(error)")
                return
            }
            
            // 2. Verify the URLError code is .cannotConnectToHost
            #expect(urlError.code == .cannotConnectToHost, "Expected .cannotConnectToHost, got \(urlError.code)")
        }
    }

    private func makeMockDataRequest(
        data: Data,
        statusCode: Int = 200
    ) -> (URLRequest) async throws -> (Data, URLResponse) {
        return { request in
            let url = request.url ?? URL(string: "http://invalid.local")!
            let response = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            return (data, response)
        }
    }

    private func makeFailingDataRequest() -> (URLRequest) async throws -> (Data, URLResponse) {
        return { _ in
            throw URLError(.cannotConnectToHost)
        }
    }

    private let mockJSON = """
{
  "results": [
    {
      "name": {
        "title": "Mr",
        "first": "John",
        "last": "Doe"
      },
      "picture": {
        "large": "https://randomuser.me/api/portraits/men/1.jpg",
        "medium": "https://randomuser.me/api/portraits/med/men/1.jpg",
        "thumbnail": "https://randomuser.me/api/portraits/thumb/men/1.jpg"
      }
    }
  ]
}
""".data(using: .utf8)!

}
