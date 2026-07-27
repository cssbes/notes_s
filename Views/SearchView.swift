import SwiftUI

struct SearchView: View {
    @State private var viewModel: SearchViewModel
    @Environment(AppCoordinator.self) private var coordinator

    init(viewModel: SearchViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar

                if viewModel.isSearching {
                    Spacer()
                    ProgressView("Searching...")
                    Spacer()
                } else if viewModel.isEmptyQuery {
                    recentSearches
                } else if !viewModel.hasResults {
                    ContentUnavailableView(
                        "No Results",
                        systemImage: "magnifyingglass",
                        description: Text("No notes match \"\(viewModel.query)\".")
                    )
                } else {
                    List {
                        ForEach(viewModel.results) { note in
                            Button {
                                coordinator.openNote(note)
                            } label: {
                                NoteRowView(note: note)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Search")
            .searchable(
                text: $viewModel.query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search notes by title, content, tags, folder..."
            )
            .onChange(of: viewModel.query) { _, newValue in
                if newValue.isEmpty {
                    viewModel.clearSearch()
                } else {
                    viewModel.search()
                }
            }
            .onSubmit(of: .search) {
                viewModel.search()
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(NoteListFilter.allCases) { filter in
                    Button {
                        viewModel.setFilter(filter)
                    } label: {
                        Text(filter.displayName)
                            .font(.subheadline)
                            .fontWeight(viewModel.filter == filter ? .semibold : .regular)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(viewModel.filter == filter ? Color.blue : Color(.systemGray6))
                            .foregroundStyle(viewModel.filter == filter ? .white : .primary)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private var recentSearches: some View {
        if !viewModel.recentSearches.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent Searches")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                ForEach(viewModel.recentSearches, id: \.self) { term in
                    Button {
                        viewModel.query = term
                        viewModel.search()
                    } label: {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundStyle(.secondary)
                            Text(term)
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top)
        } else {
            ContentUnavailableView(
                "Search Notes",
                systemImage: "magnifyingglass",
                description: Text("Search by title, content, tags, or folders.")
            )
        }
    }
}
