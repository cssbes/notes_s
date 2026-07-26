import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class TrashViewModel {
    private let noteService: NoteService

    var trashedNotes: [Note] = []
    var isLoading = false
    var errorMessage: String?
    var showEmptyConfirmation = false

    init(noteService: NoteService) {
        self.noteService = noteService
    }

    func loadTrashedNotes() {
        isLoading = true
        errorMessage = nil

        do {
            trashedNotes = try noteService.fetchNotes(filter: .trashed, sort: .updatedAtDesc)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func restoreNote(_ note: Note) {
        do {
            try noteService.restoreNote(note)
            loadTrashedNotes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func permanentlyDeleteNote(_ note: Note) {
        do {
            try noteService.permanentlyDeleteNote(note)
            loadTrashedNotes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func emptyTrash() {
        do {
            try noteService.emptyTrash()
            loadTrashedNotes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
