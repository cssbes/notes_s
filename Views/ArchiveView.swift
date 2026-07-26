import SwiftUI

struct ArchiveView: View {
    @State private var viewModel: ArchiveViewModel

    init(viewModel: ArchiveViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.archivedNotes.isEmpty {
                EmptyStateView(
                    title: "No Archived Notes",
                    message: "Archived notes will appear here.",
                    systemImage: "archivebox"
                )
            } else {
                List {
                    ForEach(viewModel.archivedNotes) { note in
                        NoteRowView(note: note)
                            .swipeActions(edge: .leading) {
                                Button {
                                    viewModel.unarchiveNote(note)
                                } label: {
                                    Label("Unarchive", systemImage: "archivebox")
                                }
                                .tint(.blue)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.deleteNote(note)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Archive")
        .onAppear { viewModel.loadArchivedNotes() }
    }
}
