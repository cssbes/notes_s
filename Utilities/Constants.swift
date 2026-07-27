import Foundation

enum Constants {
    static let appName = "Notes"
    static let appVersion = "1.1"
    static let appBuild = 1
    static let miniOSVersion = 18.0

    enum Limits {
        static let maxNoteTitleLength = 200
        static let maxNoteContentLength = 100_000
        static let maxFolderNameLength = 50
        static let maxTagNameLength = 30
        static let maxRecentNotes = 50
        static let undoStackSize = 50
    }

    enum Defaults {
        static let fontSize: Double = 16.0
        static let fontRange: ClosedRange<Double> = 12...24
    }

    enum Animation {
        static let fast: Double = 0.2
        static let medium: Double = 0.35
        static let slow: Double = 0.5
    }

    enum AutoSave {
        static let delay: Double = 1.5
    }
}
