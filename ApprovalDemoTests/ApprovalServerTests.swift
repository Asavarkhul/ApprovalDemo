import Testing
import Foundation

@testable import ApprovalDemo

struct ApprovalServerTests {

    @Test("AC-1: enrollment stores the public key and activates the device")
    func ac1_enrollActivatesDevice() async throws {
        #expect(Bool(false), "AC-1: Not yet implemented")
    }

    @Test("AC-2: a valid signature approves the request")
    func ac2_validSignatureApproves() async throws {
        #expect(Bool(false), "AC-2: Not yet implemented")
    }

    @Test("AC-3: deny marks the request denied without a signature")
    func ac3_denyMarksDenied() async throws {
        #expect(Bool(false), "AC-3: Not yet implemented")
    }

    @Test("AC-4: a replayed response is rejected")
    func ac4_replayRejected() async throws {
        #expect(Bool(false), "AC-4: Not yet implemented")
    }

    @Test("AC-5: a response after expiry is rejected")
    func ac5_expiredRejected() async throws {
        #expect(Bool(false), "AC-5: Not yet implemented")
    }

    @Test("AC-6: a signature over altered text is rejected")
    func ac6_alteredTextRejected() async throws {
        #expect(Bool(false), "AC-6: Not yet implemented")
    }

    @Test("AC-7: a signature from an unenrolled key is rejected")
    func ac7_forgedSignatureRejected() async throws {
        #expect(Bool(false), "AC-7: Not yet implemented")
    }

    @Test("AC-8: a revoked device is rejected")
    func ac8_revokedDeviceRejected() async throws {
        #expect(Bool(false), "AC-8: Not yet implemented")
    }
}
