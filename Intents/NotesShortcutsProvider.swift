import AppIntents

struct NotesShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CreateNoteIntent(),
            phrases: [
                "Create a new note with \(.applicationName)",
                "Make a note in \(.applicationName)",
                "Add note to \(.applicationName)",
            ],
            shortTitle: "New Note",
            systemImageName: "square.and.pencil"
        )
        AppShortcut(
            intent: SearchNotesIntent(),
            phrases: [
                "Search my notes in \(.applicationName)",
                "Find notes with \(.applicationName)",
            ],
            shortTitle: "Search Notes",
            systemImageName: "magnifyingglass"
        )
        AppShortcut(
            intent: CreateTaskIntent(),
            phrases: [
                "Create a task in \(.applicationName)",
                "Add task to \(.applicationName)",
                "New task in \(.applicationName)",
            ],
            shortTitle: "New Task",
            systemImageName: "checklist"
        )
        AppShortcut(
            intent: GetRecentNotesIntent(),
            phrases: [
                "Show my recent notes in \(.applicationName)",
                "Recent notes in \(.applicationName)",
            ],
            shortTitle: "Recent Notes",
            systemImageName: "clock.arrow.circlepath"
        )
    }
}
