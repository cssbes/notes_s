import Foundation
import SwiftData

@Model
final class Note {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var pinnedAt: Date?
    var isFavorite: Bool
    var isArchived: Bool
    var isTrashed: Bool
    var trashedAt: Date?
    var wordCount: Int
    var characterCount: Int
    var readingTime: Int
    var orderIndex: Int

    @Relationship(deleteRule: .cascade, inverse: \NoteBlock.note) var blocks: [NoteBlock]
    @Relationship(inverse: \Folder.notes) var folder: Folder?
    @Relationship(inverse: \Tag.notes) var tags: [Tag]

    init(
        title: String = "",
        content: String = "",
        folder: Folder? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isFavorite = false
        self.isArchived = false
        self.isTrashed = false
        self.wordCount = 0
        self.characterCount = 0
        self.readingTime = 0
        self.orderIndex = 0
        self.blocks = []
        self.folder = folder
        self.tags = []
        updateStatistics()
    }

    func updateStatistics() {
        characterCount = content.count
        wordCount = content.split { $0.isWhitespace || $0.isNewline }.count
        let wordsPerMinute = 200
        readingTime = max(1, Int(ceil(Double(wordCount) / Double(wordsPerMinute))))
    }

    var isPinned: Bool {
        pinnedAt != nil
    }

    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: updatedAt, relativeTo: Date())
    }

    var previewText: String {
        let cleaned = content
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.count > 100 {
            return String(cleaned.prefix(100)) + "..."
        }
        return cleaned
    }
}
