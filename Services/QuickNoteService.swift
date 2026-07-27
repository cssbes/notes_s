import Foundation
import UIKit

@MainActor
struct QuickNoteService {
    static func createQuickNote(title: String, noteService: NoteService) -> Note? {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
        return try? noteService.createNote(title: title)
    }
}
