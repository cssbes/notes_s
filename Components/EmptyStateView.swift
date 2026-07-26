import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    var systemImage: String = "note.text"
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } actions: {
            if let actionTitle, let action {
                Button(action: action) {
                    Label(actionTitle, systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview {
    EmptyStateView(
        title: "No Notes",
        message: "Create your first note to get started.",
        systemImage: "note.text",
        actionTitle: "New Note",
        action: {}
    )
}
