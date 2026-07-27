import SwiftUI

struct NoteListView: View {
    @State private var viewModel: NoteListViewModel
    @Environment(AppCoordinator.self) private var coordinator
    @State private var showSortPicker = false

    init(viewModel: NoteListViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.notes.isEmpty {
                EmptyStateView(
                    title: "No Notes",
                    message: "Notes you create will appear here.",
                    systemImage: "note.text",
                    actionTitle: "New Note",
                    action: {}
                )
            } else {
                List {
                    ForEach(viewModel.notes) { note in
                        Button {
                            coordinator.openNote(note)
                        } label: {
                            NoteRowView(note: note)
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .leading) {
                                Button {
                                    viewModel.toggleFavorite(note)
                                } label: {
                                    Label("Favorite", systemImage: "star")
                                }
                                .tint(.yellow)

                                Button {
                                    viewModel.togglePin(note)
                                } label: {
                                    Label("Pin", systemImage: "pin")
                                }
                                .tint(.orange)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.deleteNote(note)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button {
                                    viewModel.archiveNote(note)
                                } label: {
                                    Label("Archive", systemImage: "archivebox")
                                }
                                .tint(.gray)
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(viewModel.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 8) {
                    Button {
                        showSortPicker = true
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }

                    Button {
                        coordinator.createNewNote()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .confirmationDialog("Sort By", isPresented: $showSortPicker) {
            ForEach(SortOption.allCases) { option in
                Button(option.displayName) {
                    viewModel.setSortOption(option)
                }
            }
        }
        .onAppear { viewModel.loadNotes() }
    }
}
