import Foundation
import SwiftData

@MainActor
final class TaskService {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchTasks(showCompleted: Bool = false, sort: TaskSortOption = .dueDateAsc) throws -> [TaskItem] {
        var desc = FetchDescriptor<TaskItem>(sortBy: [sortDescriptor(for: sort)])
        if !showCompleted {
            desc.predicate = #Predicate { !$0.isCompleted }
        }
        return try context.fetch(desc)
    }

    func fetchTask(by id: UUID) throws -> TaskItem? {
        let desc = FetchDescriptor<TaskItem>(predicate: #Predicate { $0.id == id })
        return try context.fetch(desc).first
    }

    func createTask(title: String, notes: String = "", dueDate: Date? = nil, reminderDate: Date? = nil, priority: TaskPriority = .medium) throws -> TaskItem {
        let task = TaskItem(title: title, notes: notes, dueDate: dueDate, reminderDate: reminderDate, priority: priority)
        context.insert(task)
        try context.save()
        return task
    }

    func updateTask(_ task: TaskItem) throws {
        task.updatedAt = Date()
        try context.save()
    }

    func toggleComplete(_ task: TaskItem) throws {
        task.isCompleted.toggle()
        task.completedAt = task.isCompleted ? Date() : nil
        task.updatedAt = Date()
        try context.save()
    }

    func deleteTask(_ task: TaskItem) throws {
        context.delete(task)
        try context.save()
    }

    private func sortDescriptor(for sort: TaskSortOption) -> SortDescriptor<TaskItem> {
        switch sort {
        case .dueDateAsc: return SortDescriptor(\.dueDate, order: .forward)
        case .dueDateDesc: return SortDescriptor(\.dueDate, order: .reverse)
        case .createdAtDesc: return SortDescriptor(\.createdAt, order: .reverse)
        case .createdAtAsc: return SortDescriptor(\.createdAt, order: .forward)
        case .priorityDesc: return SortDescriptor(\.priorityRaw, order: .reverse)
        case .priorityAsc: return SortDescriptor(\.priorityRaw, order: .forward)
        }
    }
}

enum TaskSortOption: String, CaseIterable {
    case dueDateAsc, dueDateDesc, createdAtDesc, createdAtAsc, priorityDesc, priorityAsc

    var displayName: String {
        switch self {
        case .dueDateAsc: return "Due Date (Earliest)"
        case .dueDateDesc: return "Due Date (Latest)"
        case .createdAtDesc: return "Newest First"
        case .createdAtAsc: return "Oldest First"
        case .priorityDesc: return "Priority (High to Low)"
        case .priorityAsc: return "Priority (Low to High)"
        }
    }
}
