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
                if viewModel.isSearching {
                    Spacer()
                    ProgressView().tint(Color.themeAccent)
                    Spacer()
                } else if viewModel.isEmptyQuery {
                    recentSearches
                } else if !viewModel.hasResults {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").font(.system(size: 32)).foregroundStyle(Color.themeSubtle)
                        Text("No Results").font(.headline).foregroundStyle(Color.themeText)
                        Text("No notes match \"\(viewModel.query)\"").font(.subheadline).foregroundStyle(Color.themeSubtle)
                    }
                    Spacer()
                } else {
                    filterBar
                    List {
                        ForEach(viewModel.results) { note in
                            Button { coordinator.openNote(note) } label: { NoteRowView(note: note) }
                                .buttonStyle(.plain)
                                .listRowBackground(Color.themeCard)
                        }
                    }
                    .listStyle(.plain)
                    .background(Color.themeBackground)
                }
            }
            .background(Color.themeBackground)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
            .onChange(of: viewModel.query) { _, newValue in
                if newValue.isEmpty { viewModel.clearSearch() } else { viewModel.search() }
            }
            .onSubmit(of: .search) { viewModel.search() }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(NoteListFilter.allCases) { filter in
                    Button { viewModel.setFilter(filter) } label: {
                        Text(filter.displayName)
                            .font(.subheadline)
                            .fontWeight(viewModel.filter == filter ? .semibold : .regular)
                            .padding(.horizontal, 14).padding(.vertical, 6)
                            .background(viewModel.filter == filter ? Color.themeAccent : Color.themeCard)
                            .foregroundStyle(viewModel.filter == filter ? .white : Color.themeText)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20).padding(.vertical, 10)
        }
    }

    @ViewBuilder
    private var recentSearches: some View {
        if !viewModel.recentSearches.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.themeSubtle)
                    .textCase(.uppercase)
                    .padding(.horizontal, 20).padding(.top, 16)

                ForEach(viewModel.recentSearches, id: \.self) { term in
                    Button { viewModel.query = term; viewModel.search() } label: {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath").foregroundStyle(Color.themeSubtle)
                            Text(term).foregroundStyle(Color.themeText)
                            Spacer()
                        }
                        .padding(.horizontal, 20).padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
        } else {
            VStack(spacing: 8) {
                Image(systemName: "magnifyingglass").font(.system(size: 32)).foregroundStyle(Color.themeSubtle)
                Text("Search Notes").font(.headline).foregroundStyle(Color.themeText)
                Text("Find by title, content, tags, or folders").font(.subheadline).foregroundStyle(Color.themeSubtle)
            }
            .frame(maxHeight: .infinity)
        }
    }
}
