import AppIntents
import SwiftData

struct CreateNoteIntent: AppIntent {
    static let title: LocalizedStringResource = "Create Note"
    static let description: LocalizedStringResource = "Creates a new note"

    @Parameter(title: "Title")
    var title: String

    @Parameter(title: "Content")
    var content: String?

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<IntentNote> {
        let context = SwiftDataStack.container.mainContext
        let service = NoteService(context: context)
        let note = try service.createNote(title: title)
        if let content, !content.isEmpty {
            note.content = content
            try service.updateNote(note)
        }
        return .result(value: IntentNote(from: note))
    }
}

struct SearchNotesIntent: AppIntent {
    static let title: LocalizedStringResource = "Search Notes"
    static let description: LocalizedStringResource = "Searches your notes"

    @Parameter(title: "Query")
    var query: String

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<[IntentNote]> {
        let context = SwiftDataStack.container.mainContext
        let service = NoteService(context: context)
        let allNotes = try service.fetchNotes()
        let q = query.lowercased()
        let results = allNotes.filter { $0.title.lowercased().contains(q) || $0.content.lowercased().contains(q) }
        return .result(value: results.map(IntentNote.init))
    }
}

struct GetRecentNotesIntent: AppIntent {
    static let title: LocalizedStringResource = "Get Recent Notes"
    static let description: LocalizedStringResource = "Gets your most recent notes"

    @Parameter(title: "Limit", default: 5)
    var limit: Int

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<[IntentNote]> {
        let context = SwiftDataStack.container.mainContext
        let service = NoteService(context: context)
        let notes = try service.fetchNotes(sort: .updatedAtDesc)
        return .result(value: Array(notes.prefix(limit)).map(IntentNote.init))
    }
}

struct CreateTaskIntent: AppIntent {
    static let title: LocalizedStringResource = "Create Task"
    static let description: LocalizedStringResource = "Creates a new task"

    @Parameter(title: "Title")
    var title: String

    @Parameter(title: "Due Date")
    var dueDate: Date?

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<IntentTask> {
        let context = SwiftDataStack.container.mainContext
        let service = TaskService(context: context)
        let task = try service.createTask(title: title, dueDate: dueDate)
        return .result(value: IntentTask(from: task))
    }
}

struct GetTasksIntent: AppIntent {
    static let title: LocalizedStringResource = "Get Tasks"
    static let description: LocalizedStringResource = "Gets your incomplete tasks"

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<[IntentTask]> {
        let context = SwiftDataStack.container.mainContext
        let service = TaskService(context: context)
        let tasks = try service.fetchTasks()
        return .result(value: tasks.map(IntentTask.init))
    }
}

// MARK: - Intent Entities

struct IntentNote: Identifiable, AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Note"
    static let defaultQuery = NoteQuery()

    var id: UUID
    var title: String
    var content: String
    var updatedAt: Date

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)", subtitle: "Updated \(updatedAt.formatted())")
    }

    init(from note: Note) {
        self.id = note.id
        self.title = note.title
        self.content = note.content
        self.updatedAt = note.updatedAt
    }
}

struct NoteQuery: EntityQuery {
    @MainActor
    func entities(for ids: [UUID]) async throws -> [IntentNote] {
        let context = SwiftDataStack.container.mainContext
        let service = NoteService(context: context)
        return try ids.compactMap { try service.fetchNote(by: $0) }.map(IntentNote.init)
    }

    @MainActor
    func suggestedEntities() async throws -> [IntentNote] {
        let context = SwiftDataStack.container.mainContext
        let service = NoteService(context: context)
        return try service.fetchNotes(sort: .updatedAtDesc).prefix(10).map(IntentNote.init)
    }
}

struct IntentTask: Identifiable, AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Task"
    static let defaultQuery = TaskQuery()

    var id: UUID
    var title: String
    var isCompleted: Bool
    var dueDate: Date?

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)", subtitle: isCompleted ? "Completed" : "Active")
    }

    init(from task: TaskItem) {
        self.id = task.id
        self.title = task.title
        self.isCompleted = task.isCompleted
        self.dueDate = task.dueDate
    }
}

struct TaskQuery: EntityQuery {
    @MainActor
    func entities(for ids: [UUID]) async throws -> [IntentTask] {
        let context = SwiftDataStack.container.mainContext
        let service = TaskService(context: context)
        return try ids.compactMap { try service.fetchTask(by: $0) }.map(IntentTask.init)
    }

    @MainActor
    func suggestedEntities() async throws -> [IntentTask] {
        let context = SwiftDataStack.container.mainContext
        let service = TaskService(context: context)
        return try service.fetchTasks().prefix(10).map(IntentTask.init)
    }
}
