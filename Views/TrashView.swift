import SwiftUI

struct TrashView: View {
    @State private var viewModel: TrashViewModel
    @State private var showEmptyConfirmation = false

    init(viewModel: TrashViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.trashedNotes.isEmpty {
                EmptyStateView(
                    title: "Trash is Empty",
                    message: "Deleted notes will appear here.",
                    systemImage: "trash"
                )
            } else {
                List {
                    ForEach(viewModel.trashedNotes) { note in
                        NoteRowView(note: note)
                            .swipeActions(edge: .leading) {
                                Button {
                                    viewModel.restoreNote(note)
                                } label: {
                                    Label("Restore", systemImage: "arrow.uturn.backward")
                                }
                                .tint(.green)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.permanentlyDeleteNote(note)
                                } label: {
                                    Label("Delete", systemImage: "trash.slash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Trash")
        .toolbar {
            if !viewModel.trashedNotes.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        showEmptyConfirmation = true
                    } label: {
                        Image(systemName: "trash.slash")
                    }
                }
            }
        }
        .alert("Empty Trash?", isPresented: $showEmptyConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Empty Trash", role: .destructive) {
                viewModel.emptyTrash()
            }
        } message: {
            Text("All items in trash will be permanently deleted.")
        }
        .onAppear { viewModel.loadTrashedNotes() }
    }
}
