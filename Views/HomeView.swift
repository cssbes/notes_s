import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @Environment(AppCoordinator.self) private var coordinator
    @State private var showFolderSheet = false

    init(viewModel: HomeViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    pinnedSection
                    favoritesSection
                    foldersSection
                    tagsSection
                    recentSection
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            showFolderSheet = true
                        } label: {
                            Image(systemName: "folder.badge.plus")
                        }

                        Button {
                            coordinator.createNewNote()
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }
            }
            .searchable(text: .constant(""), prompt: "Search notes")
            .onAppear { viewModel.loadData() }
            .sheet($showFolderSheet) {
                createFolderSheet
            }
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var pinnedSection: some View {
        if !viewModel.pinnedNotes.isEmpty {
            sectionHeader("Pinned", icon: "pin.fill")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.pinnedNotes) { note in
                        Button {
                            coordinator.openNote(note)
                        } label: {
                            NoteCardView(note: note)
                                .frame(width: 200)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    @ViewBuilder
    private var favoritesSection: some View {
        if !viewModel.favoriteNotes.isEmpty {
            sectionHeader("Favorites", icon: "star.fill")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.favoriteNotes) { note in
                        Button {
                            coordinator.openNote(note)
                        } label: {
                            NoteCardView(note: note)
                                .frame(width: 200)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    @ViewBuilder
    private var foldersSection: some View {
        if !viewModel.folders.isEmpty {
            sectionHeader("Folders", icon: "folder.fill")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.folders) { folder in
                        FolderCardView(folder: folder)
                            .frame(width: 140, height: 80)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    @ViewBuilder
    private var tagsSection: some View {
        if !viewModel.tags.isEmpty {
            sectionHeader("Tags", icon: "tag.fill")
            TagListView(tags: viewModel.tags)
        }
    }

    @ViewBuilder
    private var recentSection: some View {
        sectionHeader("Recent Notes", icon: "clock")
        if viewModel.recentNotes.isEmpty {
            EmptyStateView(
                title: "No Notes Yet",
                message: "Tap the pen button to create your first note.",
                systemImage: "note.text",
                actionTitle: "New Note",
                action: { coordinator.createNewNote() }
            )
            .padding(.horizontal)
        } else {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.recentNotes.prefix(10)) { note in
                    Button {
                        coordinator.openNote(note)
                    } label: {
                        NoteRowView(note: note)
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.vertical, 2)
                }
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal)
    }

    private var createFolderSheet: some View {
        NavigationStack {
            Form {
                TextField("Folder Name", text: .constant(""))
            }
            .navigationTitle("New Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showFolderSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { showFolderSheet = false }
                }
            }
        }
        .presentationDetents([.height(200)])
    }
}

// MARK: - Card Views

struct NoteCardView: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.title.isEmpty ? "Untitled" : note.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)

            if !note.previewText.isEmpty {
                Text(note.previewText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            Spacer(minLength: 0)

            HStack {
                Text(note.formattedDate)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                if note.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}

struct FolderCardView: View {
    let folder: Folder

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: folder.icon)
                .font(.title3)
                .foregroundStyle(.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text(folder.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Text("\(folder.noteCount)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}
