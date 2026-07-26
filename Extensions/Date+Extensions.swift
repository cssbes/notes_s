import Foundation

extension Date {
    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    func formatted(dateStyle: Date.FormatStyle.DateStyle = .abbreviated, timeStyle: Date.FormatStyle.TimeStyle = .short) -> String {
        self.formatted(date: dateStyle, time: timeStyle)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    func daysBetween(_ date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: self, to: date).day ?? 0
    }
}
