import Foundation

/// An enumeration representing HTTP methods.
enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

extension URLRequest {
    /// Initializes a URLRequest with a given URL, HTTP method, and parameters.
    /// - Parameters:
    ///  - url: The URL to be used for the request.
    ///  - method: The HTTP method to be used for the request.
    ///  - parameters: The parameters to be used for the request.
    ///  - Throws: An error if the URL is invalid.
    init(url: URL, method: HTTPMethod, parameters: [String: Any]? = nil) throws {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        if let parameters = parameters, method == .GET {
            components?.queryItems = parameters.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
        }
        
        guard let finalURL = components?.url else {
            throw URLError(.badURL)
        }
        
        self.init(url: finalURL)
        httpMethod = method.rawValue
    }
}
