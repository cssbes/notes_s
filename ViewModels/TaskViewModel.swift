import Foundation
import Observation

@MainActor
@Observable
final class TaskViewModel {
    private let taskService: TaskService

    var tasks: [TaskItem] = []
    var showCompleted = false
    var sortOption: TaskSortOption = .dueDateAsc
    var isLoading = false
    var errorMessage: String?

    var overdueTasks: [TaskItem] { tasks.filter { $0.isOverdue } }
    var todayTasks: [TaskItem] { tasks.filter { !$0.isOverdue && daysUntilDue($0.dueDate) == 0 } }
    var upcomingTasks: [TaskItem] { tasks.filter { !$0.isOverdue && daysUntilDue($0.dueDate) ?? 999 > 0 } }
    var completedTasks: [TaskItem] { tasks.filter { $0.isCompleted } }
    var noDateTasks: [TaskItem] { tasks.filter { $0.dueDate == nil && !$0.isCompleted } }

    init(taskService: TaskService) {
        self.taskService = taskService
    }

    func loadTasks() {
        isLoading = true
        errorMessage = nil
        do {
            tasks = try taskService.fetchTasks(showCompleted: showCompleted, sort: sortOption)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func createTask(title: String, notes: String = "", dueDate: Date? = nil, reminderDate: Date? = nil, priority: TaskPriority = .medium) {
        do {
            let task = try taskService.createTask(title: title, notes: notes, dueDate: dueDate, reminderDate: reminderDate, priority: priority)
            if reminderDate != nil { NotificationService.shared.scheduleReminder(for: task) }
            if dueDate != nil { NotificationService.shared.scheduleDueDateReminder(for: task) }
            loadTasks()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateTask(_ task: TaskItem, title: String, notes: String, dueDate: Date?, reminderDate: Date?, priority: TaskPriority) {
        task.title = title
        task.notes = notes
        task.dueDate = dueDate
        task.reminderDate = reminderDate
        task.priority = priority
        do {
            try taskService.updateTask(task)
            NotificationService.shared.cancelReminder(for: task)
            if reminderDate != nil { NotificationService.shared.scheduleReminder(for: task) }
            if dueDate != nil { NotificationService.shared.scheduleDueDateReminder(for: task) }
            loadTasks()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleComplete(_ task: TaskItem) {
        do {
            try taskService.toggleComplete(task)
            if task.isCompleted { NotificationService.shared.cancelReminder(for: task) }
            loadTasks()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteTask(_ task: TaskItem) {
        do {
            NotificationService.shared.cancelReminder(for: task)
            try taskService.deleteTask(task)
            loadTasks()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func daysUntilDue(_ date: Date?) -> Int? {
        guard let date else { return nil }
        return Calendar.current.numberOfDaysBetween(Date(), and: date)
    }
}
