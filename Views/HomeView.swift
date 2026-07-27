import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @Environment(AppCoordinator.self) private var coordinator
    @State private var selectedCategory = 0
    let categories = ["All", "Pinned", "Favorites", "Folders"]

    init(viewModel: HomeViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                categoryTabs
                Divider().padding(.horizontal, 20)

                if viewModel.recentNotes.isEmpty {
                    emptyState
                } else {
                    noteList
                }
            }
            .background(Color.nBackground)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Notes")
                        .font(.system(size: 28, weight: .bold))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Menu {
                            Button { coordinator.selectedTab = .tasks } label: { Label("Tasks", systemImage: "checklist") }
                            Button { coordinator.selectedTab = .settings } label: { Label("Settings", systemImage: "gearshape") }
                        } label: { Image(systemName: "ellipsis.circle").font(.system(size: 15, weight: .medium)) }

                        Button { coordinator.createNewNote() } label: {
                            Image(systemName: "square.and.pencil").font(.system(size: 15, weight: .medium))
                        }
                    }
                }
            }
            .onAppear { viewModel.loadData() }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").font(.system(size: 13)).foregroundStyle(Color.nSecondary)
            TextField("Search", text: $viewModel.searchQuery)
                .font(.system(size: 15))
                .textFieldStyle(.plain)
                .onChange(of: viewModel.searchQuery) { _, _ in viewModel.search() }
            if !viewModel.searchQuery.isEmpty {
                Button { viewModel.searchQuery = ""; viewModel.searchResults = [] } label: {
                    Image(systemName: "xmark.circle.fill").font(.caption).foregroundStyle(Color.nSecondary)
                }
            }
        }
        .padding(10)
        .background(Color.nSurface)
        .cornerRadius(8)
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(categories.enumerated()), id: \.offset) { i, cat in
                    Button {
                        withAnimation(.interactiveSpring) { selectedCategory = i }
                    } label: {
                        VStack(spacing: 8) {
                            Text(cat)
                                .font(.system(size: 13, weight: selectedCategory == i ? .semibold : .regular))
                                .foregroundStyle(selectedCategory == i ? Color.nAccent : Color.nSecondary)
                            Rectangle()
                                .fill(selectedCategory == i ? Color.nAccent : Color.clear)
                                .frame(height: 2)
                                .cornerRadius(1)
                        }
                        .fixedSize()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var noteList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredNotes) { note in
                    Button { coordinator.openNote(note) } label: { NoteRowView(note: note) }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                    Divider().padding(.leading, 20).opacity(0.3)
                }
            }
            .padding(.top, 8)
        }
    }

    private var filteredNotes: [Note] {
        switch selectedCategory {
        case 1: return viewModel.pinnedNotes
        case 2: return viewModel.favoriteNotes
        default: return viewModel.recentNotes
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "note.text").font(.system(size: 40)).foregroundStyle(Color.nSecondary)
            Text("No Notes").font(.title3).fontWeight(.semibold)
            Text("Tap + to create your first note").font(.subheadline).foregroundStyle(Color.nSecondary)
            Button { coordinator.createNewNote() } label: {
                Label("New Note", systemImage: "plus").font(.subheadline.weight(.medium))
            }
            .buttonStyle(.borderedProminent).tint(Color.nAccent)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
