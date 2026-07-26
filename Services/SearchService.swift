import Foundation
import SwiftData

@MainActor
final class SearchService {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func search(query: String, filter: NoteListFilter = .all) throws -> [Note] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }

        let trimmedQuery = query.lowercased()

        let descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        let allNotes = try context.fetch(descriptor)

        return allNotes.filter { note in
            let matchesFilter: Bool = {
                switch filter {
                case .all: return !note.isArchived && !note.isTrashed
                case .favorites: return note.isFavorite && !note.isTrashed
                case .pinned: return note.pinnedAt != nil && !note.isTrashed
                case .archived: return note.isArchived && !note.isTrashed
                case .trashed: return note.isTrashed
                }
            }()

            guard matchesFilter else { return false }

            return note.title.lowercased().contains(trimmedQuery) ||
                note.content.lowercased().contains(trimmedQuery) ||
                note.tags.contains { $0.name.lowercased().contains(trimmedQuery) } ||
                note.folder?.name.lowercased().contains(trimmedQuery) == true
        }
    }
}
