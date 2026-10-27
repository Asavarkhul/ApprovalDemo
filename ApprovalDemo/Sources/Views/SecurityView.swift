import SwiftUI

struct SecurityView: View {

    @State private var viewModel = ApprovalViewModel()

    var body: some View {
        NavigationStack {
            Form {
                if viewModel.mode == .simulator {
                    Section {
                        Label(
                            "Simulator: the key is not bound to Face ID. At the Face ID prompt, choose Features > Face ID > Matching Face.",
                            systemImage: "exclamationmark.triangle"
                        )
                        .font(.footnote)
                    }
                }

                Section {
                    if viewModel.deviceID == nil {
                        Button("Enable Face ID approval") { Task { await viewModel.enable() } }
                    } else {
                        Button("Simulate sign-in attempt") { Task { await viewModel.simulate() } }
                        Button("Disable", role: .destructive) { Task { await viewModel.disable() } }
                    }
                } header: {
                    Text("Device")
                } footer: {
                    Text(deviceFooter)
                }

                if let request = viewModel.request {
                    Section {
                        RequestCard(request: request)
                        Button("Approve with Face ID") { Task { await viewModel.approve() } }
                        Button("Deny", role: .destructive) { Task { await viewModel.deny() } }
                    } header: {
                        Text("Pending request")
                    } footer: {
                        Text("Approving signs this exact text with the key. The server checks the signature before accepting.")
                    }
                }

                if let message = viewModel.message {
                    Section {
                        Text(message)
                        if viewModel.canReplay {
                            Button("Try an attack: replay this approval") { Task { await viewModel.replay() } }
                        }
                    } header: {
                        Text("Result")
                    } footer: {
                        if viewModel.canReplay {
                            Text("An attacker who captured the signed response sends it again. The server must refuse it.")
                        }
                    }
                }

                // Newest first, right under the result: this is where the server's checks become visible.
                if !viewModel.log.isEmpty {
                    Section("Server log") {
                        ForEach(viewModel.log.reversed()) { entry in
                            AuditRow(entry: entry)
                        }
                    }
                }
            }
            .disabled(viewModel.isWorking)
            .navigationTitle("Security")
            .toolbar {
                if viewModel.isWorking {
                    ProgressView()
                }
            }
        }
    }

    private var deviceFooter: String {
        if viewModel.deviceID == nil {
            return "Creates a key in the Secure Enclave, a chip that never lets the key out, and sends its public half to the server."
        }

        return "Simulates someone signing in on another device. The request appears below."
    }
}

#Preview {
    SecurityView()
}
