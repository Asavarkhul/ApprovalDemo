import SwiftUI

struct SecurityView: View {

    @State private var viewModel = ApprovalViewModel()

    var body: some View {
        NavigationStack {
            Form {
                if viewModel.mode == .simulator {
                    Section {
                        Label("Simulator mode: the key is not bound to Face ID.", systemImage: "exclamationmark.triangle")
                    }
                }

                Section("Device") {
                    if viewModel.deviceID == nil {
                        Button("Enable Face ID approval") { Task { await viewModel.enable() } }
                    } else {
                        Button("Simulate sign-in attempt") { Task { await viewModel.simulate() } }
                        Button("Disable", role: .destructive) { Task { await viewModel.disable() } }
                    }
                }

                if let request = viewModel.request {
                    Section("Pending request") {
                        Text(request.context)
                        Button("Approve") { Task { await viewModel.approve() } }
                        Button("Deny", role: .destructive) { Task { await viewModel.deny() } }
                    }
                }

                if let message = viewModel.message {
                    Section("Result") {
                        Text(message)
                    }
                }
            }
            .navigationTitle("Security")
        }
    }
}

#Preview {
    SecurityView()
}
