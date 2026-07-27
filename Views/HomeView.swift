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
                VStack(alignment: .leading, spacing: 20) {
                    statsGrid
                    quickSearchBar
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
                            coordinator.selectedTab = .folders
                        } label: {
                            Image(systemName: "folder")
                        }

                        Button {
                            coordinator.selectedTab = .search
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }

                        Button {
                            coordinator.createNewNote()
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .onAppear { viewModel.loadData() }
            .sheet(isPresented: $showFolderSheet) {
                createFolderSheet
            }
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCard(value: "\(viewModel.totalNotes)", label: "Notes", icon: "note.text", color: .blue)
            statCard(value: "\(viewModel.totalFolders)", label: "Folders", icon: "folder.fill", color: .orange)
            statCard(value: "\(viewModel.totalTags)", label: "Tags", icon: "tag.fill", color: .green)
            statCard(value: "\(viewModel.totalPinned)", label: "Pinned", icon: "pin.fill", color: .red)
            statCard(value: "\(viewModel.totalFavorites)", label: "Favorites", icon: "star.fill", color: .yellow)
            statCard(value: "\(viewModel.totalWords)", label: "Words", icon: "text.word.count", color: .purple)
        }
        .padding(.horizontal)
    }

    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(
            LinearGradient(
                colors: [Color(.systemBackground), color.opacity(0.06)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: color.opacity(0.08), radius: 6, y: 3)
    }

    // MARK: - Quick Search

    @ViewBuilder
    private var quickSearchBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search notes...", text: $viewModel.searchQuery)
                    .textFieldStyle(.plain)
                    .onChange(of: viewModel.searchQuery) { _, _ in viewModel.search() }
                if !viewModel.searchQuery.isEmpty {
                    Button {
                        viewModel.searchQuery = ""
                        viewModel.searchResults = []
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(12)

            if !viewModel.searchResults.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.searchResults.prefix(5)) { note in
                        Button {
                            coordinator.openNote(note)
                        } label: {
                            HStack {
                                Text(note.displayEmoji)
                                    .font(.title3)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(note.displayTitle)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(note.previewText)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
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
                            .frame(width: 150, height: 80)
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
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.vertical, 2)
                }
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.tint)
                .frame(width: 24, height: 24)
                .background(.tint.opacity(0.1))
                .cornerRadius(6)
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
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

// MARK: - Note Card

struct NoteCardView: View {
    let note: Note

    private var cardColor: Color {
        Color(hex: note.colorHex) ?? .blue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if !note.emoji.isEmpty {
                    Text(note.emoji)
                        .font(.title2)
                }
                Spacer()
                if note.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                }
            }

            Text(note.displayTitle)
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
                if note.wordCount > 0 {
                    Text("\(note.wordCount)w")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(14)
        .background(
            ZStack {
                Color(.systemBackground)
                if !note.colorHex.isEmpty {
                    cardColor.opacity(0.06)
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(cardColor.opacity(0.15), lineWidth: 1)
        )
        .cornerRadius(16)
        .shadow(color: cardColor.opacity(0.08), radius: 8, y: 4)
    }
}

// MARK: - Folder Card

struct FolderCardView: View {
    let folder: Folder

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: folder.icon)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 36, height: 36)
                .background(.tint.opacity(0.1))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 3) {
                Text(folder.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Text("\(folder.noteCount) notes")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.forward")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
    }
}
