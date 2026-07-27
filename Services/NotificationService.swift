import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func scheduleReminder(for task: TaskItem) {
        guard let reminderDate = task.reminderDate, reminderDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title
        content.sound = .default
        content.badge = 1

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "task-\(task.id.uuidString)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleDueDateReminder(for task: TaskItem) {
        guard let dueDate = task.dueDate, dueDate > Date() else { return }
        let dayBefore = Calendar.current.date(byAdding: .day, value: -1, to: dueDate)
        guard let reminder = dayBefore, reminder > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Task Due Tomorrow"
        content.body = task.title
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "due-\(task.id.uuidString)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func cancelReminder(for task: TaskItem) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            "task-\(task.id.uuidString)",
            "due-\(task.id.uuidString)"
        ])
    }
}
