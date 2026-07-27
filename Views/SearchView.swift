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
                    ProgressView().tint(Color.nAccent)
                    Spacer()
                } else if viewModel.isEmptyQuery {
                    recentSearches
                } else if !viewModel.hasResults {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").font(.system(size: 32)).foregroundStyle(Color.nSecondary)
                        Text("No Results").font(.headline)
                        Text("No notes match \"\(viewModel.query)\"").font(.subheadline).foregroundStyle(Color.nSecondary)
                    }
                    Spacer()
                } else {
                    filterBar
                    Divider().padding(.horizontal, 20).opacity(0.3)
                    List {
                        ForEach(viewModel.results) { note in
                            Button { coordinator.openNote(note) } label: { NoteRowView(note: note) }
                                .buttonStyle(.plain)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color.nBackground)
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
            HStack(spacing: 0) {
                ForEach(NoteListFilter.allCases) { filter in
                    Button { viewModel.setFilter(filter) } label: {
                        VStack(spacing: 8) {
                            Text(filter.displayName)
                                .font(.system(size: 13, weight: viewModel.filter == filter ? .semibold : .regular))
                                .foregroundStyle(viewModel.filter == filter ? Color.nAccent : Color.nSecondary)
                            Rectangle()
                                .fill(viewModel.filter == filter ? Color.nAccent : Color.clear)
                                .frame(height: 2).cornerRadius(1)
                        }
                        .fixedSize()
                        .padding(.horizontal, 14).padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    @ViewBuilder
    private var recentSearches: some View {
        if !viewModel.recentSearches.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text("Recent").font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.nSecondary).textCase(.uppercase)
                    .padding(.horizontal, 20).padding(.top, 16)
                ForEach(viewModel.recentSearches, id: \.self) { term in
                    Button { viewModel.query = term; viewModel.search() } label: {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath").font(.caption).foregroundStyle(Color.nSecondary)
                            Text(term).font(.system(size: 15))
                            Spacer()
                        }
                        .padding(.horizontal, 20).padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
        } else {
            VStack(spacing: 8) {
                Image(systemName: "magnifyingglass").font(.system(size: 32)).foregroundStyle(Color.nSecondary)
                Text("Search Notes").font(.headline)
                Text("Find by title, content, tags, or folders").font(.subheadline).foregroundStyle(Color.nSecondary)
            }
            .frame(maxHeight: .infinity)
        }
    }
}
