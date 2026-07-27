import SwiftUI

@main
struct NotesApp: App {
    @State private var coordinator = AppCoordinator(container: AppDependencyContainer())
    @AppStorage("accentColorHex") private var accentColorHex = "#007AFF"
    @AppStorage("themeRaw") private var themeRaw = AppTheme.system.rawValue

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(coordinator)
                .tint(Color(hex: accentColorHex) ?? .blue)
                .preferredColorScheme(colorScheme)
        }
    }

    private var colorScheme: ColorScheme? {
        switch AppTheme(rawValue: themeRaw) ?? .system {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
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

            NoteListView(viewModel: coordinator.container.makeNoteListViewModel())
                .tabItem {
                    Label("All Notes", systemImage: "note.text")
                }
                .tag(AppCoordinator.Tab.folders)

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
