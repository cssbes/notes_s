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
                filterPicker

                if viewModel.isSearching {
                    Spacer()
                    ProgressView("Searching...")
                    Spacer()
                } else if viewModel.isEmptyQuery {
                    EmptyStateView(
                        title: "Search Notes",
                        message: "Search by title, content, tags, or folders.",
                        systemImage: "magnifyingglass"
                    )
                } else if !viewModel.hasResults {
                    EmptyStateView(
                        title: "No Results",
                        message: "No notes match \"\(viewModel.query)\".",
                        systemImage: "magnifyingglass"
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
                prompt: "Search notes"
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

    private var filterPicker: some View {
        Picker("Filter", selection: $viewModel.filter) {
            ForEach(NoteListFilter.allCases) { filter in
                Text(filter.displayName).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding()
        .onChange(of: viewModel.filter) { _, _ in
            viewModel.search()
        }
    }
}
