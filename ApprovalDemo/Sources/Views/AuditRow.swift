import SwiftUI

struct AuditRow: View {
    let entry: AuditEntry

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.text)
                Text(entry.date.formatted(date: .omitted, time: .standard))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: symbol)
                .foregroundStyle(color)
        }
    }

    private var symbol: String {
        switch entry.outcome {
        case .info:
            return "info.circle"
        case .success:
            return "checkmark.seal.fill"
        case .failure:
            return "xmark.octagon.fill"
        }
    }

    private var color: Color {
        switch entry.outcome {
        case .info:
            return .secondary
        case .success:
            return .green
        case .failure:
            return .red
        }
    }
}
