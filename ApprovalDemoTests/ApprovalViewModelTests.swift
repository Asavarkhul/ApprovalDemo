import Testing
import Foundation

@testable import ApprovalDemo

@MainActor
struct ApprovalViewModelTests {

    @Test("AC-9: a Face ID failure sends nothing and keeps the request pending")
    func ac9_faceIDFailureSendsNothing() async throws {
        // GIVEN: an enrolled device and a pending request
        let server = ApprovalServer()
        let viewModel = ApprovalViewModel(server: server, key: MockDeviceKey(outcome: .failure))
        await viewModel.enable()
        await viewModel.simulate()
        let request = try #require(viewModel.request)

        // WHEN: Face ID fails
        await viewModel.approve()

        // THEN: the server still holds a pending request
        #expect(await server.request(request.id)?.status == .pending)
        #expect(viewModel.request != nil)
    }

    @Test("Replaying the last approval is rejected and shown to the user")
    func replayIsRejected() async throws {
        // GIVEN: an approved request
        let viewModel = ApprovalViewModel(server: ApprovalServer(), key: MockDeviceKey(outcome: .success))
        await viewModel.enable()
        await viewModel.simulate()
        await viewModel.approve()
        #expect(viewModel.canReplay)

        // WHEN: the signed response is sent again
        await viewModel.replay()

        // THEN: the server refuses it and the log shows why
        #expect(viewModel.message == "Replay rejected: \(ApprovalError.alreadyUsed.localizedDescription)")
        #expect(viewModel.log.last?.outcome == .failure)
    }
}
