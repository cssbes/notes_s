import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @Environment(AppCoordinator.self) private var coordinator
    @State private var showFolderSheet = false
    @State private var hasAppeared = false

    init(viewModel: HomeViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    statsGrid
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 20)
                    quickSearchBar
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 15)
                    pinnedSection
                    favoritesSection
                    foldersSection
                    tagsSection
                    recentSection
                }
                .padding(.top, 8)
                .padding(.bottom, 80)
            }
            .background(Color.premiumBackground)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Notes")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 14) {
                        Button {
                            coordinator.selectedTab = .folders
                        } label: {
                            Image(systemName: "folder")
                                .font(.system(size: 16, weight: .medium))
                        }

                        Button {
                            coordinator.selectedTab = .search
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16, weight: .medium))
                        }

                        Button {
                            coordinator.createNewNote()
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                }
            }
            .onAppear {
                viewModel.loadData()
                withAnimation(.easeOut(duration: 0.6)) {
                    hasAppeared = true
                }
            }
            .sheet(isPresented: $showFolderSheet) {
                createFolderSheet
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Notes")
                .font(.system(size: 34, weight: .bold, design: .rounded))
            Text("\(viewModel.totalNotes) total notes")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 10) {
            statCard(value: "\(viewModel.totalNotes)", label: "Notes", icon: "note.text", color: .blue)
            statCard(value: "\(viewModel.totalFolders)", label: "Folders", icon: "folder.fill", color: .orange)
            statCard(value: "\(viewModel.totalTags)", label: "Tags", icon: "tag.fill", color: .green)
            statCard(value: "\(viewModel.totalPinned)", label: "Pinned", icon: "pin.fill", color: .red)
            statCard(value: "\(viewModel.totalFavorites)", label: "Fav", icon: "star.fill", color: .yellow)
            statCard(value: "\(viewModel.totalWords)", label: "Words", icon: "text.word.count", color: .purple)
        }
        .padding(.horizontal, 16)
    }

    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12))
                .cornerRadius(8)

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .monospacedDigit()

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.03), radius: 6, y: 3)
    }

    // MARK: - Quick Search

    @ViewBuilder
    private var quickSearchBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 15, weight: .medium))
                TextField("Search notes...", text: $viewModel.searchQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 15))
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
            .padding(14)
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.03), radius: 6, y: 3)

            if !viewModel.searchResults.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.searchResults.prefix(5)) { note in
                        Button {
                            coordinator.openNote(note)
                        } label: {
                            HStack(spacing: 12) {
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
                                Image(systemName: "chevron.forward")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                        if note.id != viewModel.searchResults.prefix(5).last?.id {
                            Divider().padding(.leading, 14)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.03), radius: 6, y: 3)
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Sections

    @ViewBuilder
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
            Spacer()
            Image(systemName: "chevron.forward")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
    }

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
                .padding(.horizontal, 16)
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
                .padding(.horizontal, 16)
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
                .padding(.horizontal, 16)
            }
        }
    }

    @ViewBuilder
    private var tagsSection: some View {
        if !viewModel.tags.isEmpty {
            sectionHeader("Tags", icon: "tag.fill")
            TagListView(tags: viewModel.tags)
                .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Recent Notes", icon: "clock")

            if viewModel.recentNotes.isEmpty {
                EmptyStateView(
                    title: "No Notes Yet",
                    message: "Tap the pen button to create your first note.",
                    systemImage: "note.text",
                    actionTitle: "New Note",
                    action: { coordinator.createNewNote() }
                )
                .padding(.horizontal, 16)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.recentNotes.prefix(10)) { note in
                        Button {
                            coordinator.openNote(note)
                        } label: {
                            NoteRowView(note: note)
                                .padding(14)
                                .background(Color(.systemBackground))
                                .cornerRadius(14)
                                .shadow(color: .black.opacity(0.03), radius: 6, y: 3)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
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
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if !note.emoji.isEmpty {
                    Text(note.emoji)
                        .font(.title2)
                } else {
                    Image(systemName: "note.text")
                        .font(.title3)
                        .foregroundStyle(cardColor)
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
                        .monospacedDigit()
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(cardColor.opacity(0.12), lineWidth: 1)
        )
        .cornerRadius(16)
        .shadow(color: cardColor.opacity(0.06), radius: 8, y: 4)
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
