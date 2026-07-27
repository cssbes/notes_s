import SwiftUI

struct NoteListView: View {
    @State private var viewModel: NoteListViewModel
    @Environment(AppCoordinator.self) private var coordinator
    @State private var showSortPicker = false
    @State private var showFolderPicker = false
    @State private var selectedNote: Note?
    @State private var multiSelection = Set<UUID>()

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
                    action: { coordinator.createNewNote() }
                )
            } else {
                List(selection: $multiSelection) {
                    ForEach(viewModel.notes) { note in
                        Button {
                            coordinator.openNote(note)
                        } label: {
                            NoteRowView(note: note)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Section {
                                Button {
                                    viewModel.toggleFavorite(note)
                                } label: {
                                    Label(note.isFavorite ? "Unfavorite" : "Favorite", systemImage: note.isFavorite ? "star.slash" : "star")
                                }
                                Button {
                                    viewModel.togglePin(note)
                                } label: {
                                    Label(note.isPinned ? "Unpin" : "Pin", systemImage: note.isPinned ? "pin.slash" : "pin")
                                }
                            }
                            Section {
                                Button {
                                    selectedNote = note
                                    showFolderPicker = true
                                } label: {
                                    Label("Move to Folder", systemImage: "folder")
                                }
                                Button {
                                    duplicateNote(note)
                                } label: {
                                    Label("Duplicate", systemImage: "doc.on.doc")
                                }
                            }
                            Section {
                                Button(role: .destructive) {
                                    viewModel.archiveNote(note)
                                } label: {
                                    Label("Archive", systemImage: "archivebox")
                                }
                                Button(role: .destructive) {
                                    viewModel.deleteNote(note)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
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
        .sheet(isPresented: $showFolderPicker) {
            if let note = selectedNote {
                folderPickerSheet(for: note)
            }
        }
        .onAppear { viewModel.loadNotes() }
    }

    private func duplicateNote(_ note: Note) {
        viewModel.duplicateNote(note)
    }

    private func folderPickerSheet(for note: Note) -> some View {
        NavigationStack {
            FolderPickerView(
                noteService: coordinator.container.noteService,
                selectedFolder: note.folder
            ) { folder in
                viewModel.moveNote(note, to: folder)
                showFolderPicker = false
            }
        }
    }
}
