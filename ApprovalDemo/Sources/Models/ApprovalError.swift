enum ApprovalError: Error, Equatable {
    case unknownRequest
    case unknownDevice
    case expired
    case alreadyUsed
    case invalidSignature
    case deviceRevoked
}
