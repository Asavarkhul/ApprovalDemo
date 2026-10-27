import Foundation

enum ApprovalError: Error, Equatable {
    case unknownRequest
    case unknownDevice
    case expired
    case alreadyUsed
    case invalidSignature
    case deviceRevoked
}

extension ApprovalError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unknownRequest:
            return "This request does not exist."
        case .unknownDevice:
            return "This device is not enrolled."
        case .expired:
            return "This request expired."
        case .alreadyUsed:
            return "This request was already answered."
        case .invalidSignature:
            return "The signature does not match the request."
        case .deviceRevoked:
            return "This device was disabled."
        }
    }
}
