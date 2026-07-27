import Foundation
import SwiftData

@MainActor
final class InsightsService {
    let noteService: NoteService

    init(noteService: NoteService) {
        self.noteService = noteService
    }

    var totalNotes: Int { (try? noteService.fetchNotes().count) ?? 0 }
    var totalWords: Int { (try? noteService.fetchNotes().reduce(0) { $0 + $1.wordCount }) ?? 0 }
    var totalPinned: Int { (try? noteService.fetchNotes(filter: .pinned).count) ?? 0 }
    var totalFavorites: Int { (try? noteService.fetchNotes(filter: .favorites).count) ?? 0 }
    var totalFolders: Int { (try? noteService.fetchFolders().count) ?? 0 }
    var totalTags: Int { (try? noteService.fetchTags().count) ?? 0 }
    var totalTasks: Int {
        let desc = FetchDescriptor<TaskItem>()
        return (try? noteService.context.fetch(desc).count) ?? 0
    }

    var averageWordsPerNote: Int {
        let notes = (try? noteService.fetchNotes()) ?? []
        let count = notes.count
        guard count > 0 else { return 0 }
        return notes.reduce(0) { $0 + $1.wordCount } / count
    }

    var longestNote: String? {
        let notes = (try? noteService.fetchNotes()) ?? []
        return notes.max(by: { $0.wordCount < $1.wordCount })?.title
    }

    var thisWeekNotes: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let notes = (try? noteService.fetchNotes()) ?? []
        return notes.filter { $0.createdAt >= weekAgo }.count
    }

    var thisWeekWords: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let notes = (try? noteService.fetchNotes()) ?? []
        return notes.filter { $0.createdAt >= weekAgo }.reduce(0) { $0 + $1.wordCount }
    }

    var currentStreak: Int {
        let notes = (try? noteService.fetchNotes(sort: .createdAtDesc)) ?? []
        guard !notes.isEmpty else { return 0 }

        var streak = 0
        let cal = Calendar.current
        var currentDate = cal.startOfDay(for: Date())

        for offset in 0..<365 {
            let checkDate = cal.date(byAdding: .day, value: -offset, to: currentDate)!
            let hasNote = notes.contains { cal.isDate($0.createdAt, inSameDayAs: checkDate) }
            if hasNote {
                streak += 1
            } else if offset > 0 {
                break
            }
        }
        return streak
    }

    var activeDaysLastMonth: Int {
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        let notes = (try? noteService.fetchNotes()) ?? []
        let days = Set(notes.filter { $0.createdAt >= monthAgo }.map { Calendar.current.startOfDay(for: $0.createdAt) })
        return days.count
    }
}
