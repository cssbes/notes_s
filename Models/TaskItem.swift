import Foundation
import SwiftData

enum TaskPriority: String, Codable, CaseIterable {
    case low, medium, high

    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

@Model
final class TaskItem: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var notes: String
    var dueDate: Date?
    var reminderDate: Date?
    var isCompleted: Bool
    var completedAt: Date?
    var priorityRaw: String
    var createdAt: Date
    var updatedAt: Date
    var orderIndex: Int

    var priority: TaskPriority {
        get { TaskPriority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }

    var daysRemaining: Int? {
        guard let dueDate else { return nil }
        return Calendar.current.numberOfDaysBetween(Date(), and: dueDate)
    }

    var isOverdue: Bool {
        guard let dueDate else { return false }
        return dueDate < Date() && !isCompleted
    }

    var formattedDueDate: String {
        guard let dueDate else { return "" }
        let fmt = RelativeDateTimeFormatter()
        fmt.unitsStyle = .abbreviated
        return fmt.localizedString(for: dueDate, relativeTo: Date())
    }

    init(
        title: String,
        notes: String = "",
        dueDate: Date? = nil,
        reminderDate: Date? = nil,
        priority: TaskPriority = .medium
    ) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.reminderDate = reminderDate
        self.isCompleted = false
        self.priorityRaw = priority.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
        self.orderIndex = 0
    }
}

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let start = startOfDay(for: from)
        let end = startOfDay(for: to)
        return difference(.day, between: start, and: end)
    }
}
