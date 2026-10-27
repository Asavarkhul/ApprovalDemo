import SwiftUI

// A pending request as a bank app shows it: what happened, and how long is left to answer.
struct RequestCard: View {
    let request: ApprovalRequest

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "laptopcomputer")
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(request.context)
                    .font(.headline)

                // Switches to "Expired" once the server would refuse the answer.
                TimelineView(.periodic(from: .now, by: 1)) { timeline in
                    if timeline.date < request.expiresAt {
                        Text("Expires in \(Text(timerInterval: timeline.date...request.expiresAt, countsDown: true))")
                    } else {
                        Text("Expired")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
