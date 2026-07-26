import SwiftUI

@main
struct NotesApp: App {
    @State private var coordinator = AppCoordinator(container: AppDependencyContainer())

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(coordinator)
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
