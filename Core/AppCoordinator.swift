import SwiftUI

@MainActor
@Observable
final class AppCoordinator {
    let container: AppDependencyContainer
    var selectedTab: Tab = .home
    var selectedNote: Note?
    var showNoteEditor = false
    var editingNote: Note?

    enum Tab: String, CaseIterable {
        case home
        case search
        case settings

        var title: String {
            switch self {
            case .home: return "Home"
            case .search: return "Search"
            case .settings: return "Settings"
            }
        }

        var icon: String {
            switch self {
            case .home: return "house"
            case .search: return "magnifyingglass"
            case .settings: return "gearshape"
            }
        }
    }

    init(container: AppDependencyContainer) {
        self.container = container
    }

    func openNote(_ note: Note) {
        editingNote = note
        showNoteEditor = true
    }

    func createNewNote() {
        editingNote = nil
        showNoteEditor = true
    }

    func dismissEditor() {
        editingNote = nil
        showNoteEditor = false
    }
}
