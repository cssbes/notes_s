import SwiftUI
import SwiftData

@main
struct NotesApp: App {
    @State private var coordinator: AppCoordinator?
    @State private var initializationError: String?

    var body: some Scene {
        WindowGroup {
            if let error = initializationError {
                ContentUnavailableView(
                    "Initialization Failed",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error)
                )
            } else if let coordinator {
                MainTabView(coordinator: coordinator)
                    .environment(coordinator)
            } else {
                ProgressView("Loading...")
                    .task {
                        do {
                            let container = try AppDependencyContainer()
                            self.coordinator = AppCoordinator(container: container)
                        } catch {
                            self.initializationError = error.localizedDescription
                        }
                    }
            }
        }
    }
}

struct MainTabView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator

        TabView(selection: $coordinator.selectedTab) {
            HomeView(viewModel: coordinator.container.makeHomeViewModel())
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(AppCoordinator.Tab.home)

            SearchView(viewModel: coordinator.container.makeSearchViewModel())
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(AppCoordinator.Tab.search)

            SettingsView(viewModel: coordinator.container.makeSettingsViewModel())
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(AppCoordinator.Tab.settings)
        }
        .fullScreenCover(isPresented: $coordinator.showNoteEditor) {
            NavigationStack {
                if let note = coordinator.editingNote {
                    NoteEditorView(
                        viewModel: coordinator.container.makeNoteEditorViewModel(note: note)
                    )
                } else {
                    NoteEditorView(
                        viewModel: coordinator.container.makeNoteEditorViewModel()
                    )
                }
            }
        }
    }
}
