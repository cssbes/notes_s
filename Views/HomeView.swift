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
                VStack(alignment: .leading, spacing: 32) {
                    headerSection
                    quickSearchBar
                    if !viewModel.pinnedNotes.isEmpty || !viewModel.favoriteNotes.isEmpty {
                        highlightsSection
                    }
                    foldersSection
                    tagsSection
                    recentSection
                }
                .padding(.bottom, 40)
            }
            .background(Color.themeBackground)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Notes")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.themeText)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button { coordinator.selectedTab = .search } label: {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(Color.themeText)
                                .font(.system(size: 15, weight: .medium))
                        }
                        Button { coordinator.createNewNote() } label: {
                            Image(systemName: "plus")
                                .foregroundStyle(Color.themeAccent)
                                .font(.system(size: 15, weight: .semibold))
                        }
                    }
                }
            }
            .onAppear { viewModel.loadData() }
            .sheet(isPresented: $showFolderSheet) { createFolderSheet }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Good \(timeOfDay())")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(Color.themeSubtle)
            Text("You have \(viewModel.totalNotes) notes")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(Color.themeSubtle)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func timeOfDay() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Morning"
        case 12..<17: return "Afternoon"
        default: return "Evening"
        }
    }

    private var quickSearchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.themeSubtle)
                .font(.system(size: 14))
            TextField("Search", text: $viewModel.searchQuery)
                .textFieldStyle(.plain)
                .font(.system(size: 15, design: .rounded))
                .onChange(of: viewModel.searchQuery) { _, _ in viewModel.search() }
            if !viewModel.searchQuery.isEmpty {
                Button { viewModel.searchQuery = ""; viewModel.searchResults = [] } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(Color.themeSubtle)
                }
            }
        }
        .padding(14)
        .background(Color.themeCard)
        .cornerRadius(12)
        .padding(.horizontal, 20)

        if !viewModel.searchResults.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.searchResults.prefix(5)) { note in
                    Button {
                        coordinator.openNote(note)
                    } label: {
                        HStack(spacing: 12) {
                            Text(note.displayEmoji).font(.title3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(note.displayTitle).font(.subheadline).fontWeight(.medium)
                                Text(note.previewText).font(.caption).foregroundStyle(Color.themeSubtle).lineLimit(1)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20).padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(Color.themeSurface)
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
    }

    @ViewBuilder
    private var highlightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Highlights")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    if !viewModel.pinnedNotes.isEmpty {
                        ForEach(viewModel.pinnedNotes.prefix(3)) { note in
                            miniCard(note)
                        }
                    }
                    if !viewModel.favoriteNotes.isEmpty {
                        ForEach(viewModel.favoriteNotes.prefix(3)) { note in
                            miniCard(note)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func miniCard(_ note: Note) -> some View {
        Button {
            coordinator.openNote(note)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(note.displayEmoji).font(.title3)
                Text(note.displayTitle).font(.subheadline).fontWeight(.semibold).lineLimit(2)
                Text(note.formattedDate).font(.caption2).foregroundStyle(Color.themeSubtle)
            }
            .frame(width: 140, alignment: .leading)
            .padding(14)
            .background(Color.themeCard)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var foldersSection: some View {
        if !viewModel.folders.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                sectionTitle("Folders")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.folders) { folder in
                            folderMiniCard(folder)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    private func folderMiniCard(_ folder: Folder) -> some View {
        HStack(spacing: 10) {
            Image(systemName: folder.icon).font(.system(size: 14)).foregroundStyle(Color.themeAccent)
            VStack(alignment: .leading, spacing: 1) {
                Text(folder.name).font(.subheadline).fontWeight(.medium)
                Text("\(folder.noteCount)").font(.caption2).foregroundStyle(Color.themeSubtle)
            }
        }
        .padding(12)
        .background(Color.themeCard)
        .cornerRadius(10)
    }

    @ViewBuilder
    private var tagsSection: some View {
        if !viewModel.tags.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                sectionTitle("Tags")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.tags) { tag in
                            Text("#\(tag.name)")
                                .font(.subheadline)
                                .foregroundStyle(Color.themeSubtle)
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(Color.themeCard)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    @ViewBuilder
    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Recent")

            if viewModel.recentNotes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "note.text").font(.system(size: 36)).foregroundStyle(Color.themeSubtle)
                    Text("No notes yet").font(.headline).foregroundStyle(Color.themeText)
                    Text("Tap + to create your first note").font(.subheadline).foregroundStyle(Color.themeSubtle)
                    Button("New Note") { coordinator.createNewNote() }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.themeAccent)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.recentNotes.prefix(10)) { note in
                        Button { coordinator.openNote(note) } label: {
                            NoteRowView(note: note)
                                .padding(14)
                                .background(Color.themeCard)
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.themeSubtle)
            .textCase(.uppercase)
            .padding(.horizontal, 20)
    }

    private var createFolderSheet: some View {
        NavigationStack {
            Form {
                TextField("Folder Name", text: .constant(""))
            }
            .navigationTitle("New Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { showFolderSheet = false } }
                ToolbarItem(placement: .confirmationAction) { Button("Create") { showFolderSheet = false } }
            }
        }
        .presentationDetents([.height(200)])
    }
}
