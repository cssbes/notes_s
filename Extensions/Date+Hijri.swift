import Foundation

extension Date {
    var hijriFull: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .islamicUmmAlQura)
        formatter.locale = Locale(identifier: "ar")
        formatter.dateStyle = .full
        return formatter.string(from: self)
    }

    var hijriShort: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .islamicUmmAlQura)
        formatter.locale = Locale(identifier: "ar")
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: self)
    }

    var hijriDayMonth: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .islamicUmmAlQura)
        formatter.locale = Locale(identifier: "ar")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: self)
    }

    var gregorianFull: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar")
        formatter.dateStyle = .full
        return formatter.string(from: self)
    }

    var dualDate: String {
        "\(gregorianFull) — \(hijriFull)"
    }
}
