import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class ArchiveViewModel {
    private let noteService: NoteService

    var archivedNotes: [Note] = []
    var isLoading = false
    var errorMessage: String?

    init(noteService: NoteService) {
        self.noteService = noteService
    }

    func loadArchivedNotes() {
        isLoading = true
        errorMessage = nil

        do {
            archivedNotes = try noteService.fetchNotes(filter: .archived, sort: .updatedAtDesc)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func unarchiveNote(_ note: Note) {
        do {
            try noteService.unarchiveNote(note)
            loadArchivedNotes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteNote(_ note: Note) {
        do {
            try noteService.deleteNote(note)
            loadArchivedNotes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleFavorite(_ note: Note) {
        do {
            try noteService.toggleFavorite(note)
            loadArchivedNotes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
