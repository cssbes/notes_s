import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class NoteListViewModel {
    private let noteService: NoteService

    var notes: [Note] = []
    var filter: NoteListFilter = .all
    var sortOption: SortOption = .updatedAtDesc
    var selectedFolder: Folder?
    var selectedTag: Tag?
    var isLoading = false
    var errorMessage: String?

    var title: String {
        if let folder = selectedFolder {
            return folder.name
        }
        if let tag = selectedTag {
            return "#\(tag.name)"
        }
        return filter.displayName
    }

    init(noteService: NoteService) {
        self.noteService = noteService
    }

    func loadNotes() {
        isLoading = true
        errorMessage = nil

        do {
            notes = try noteService.fetchNotes(
                filter: filter,
                sort: sortOption,
                folder: selectedFolder,
                tag: selectedTag
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func setFilter(_ filter: NoteListFilter) {
        self.filter = filter
        selectedFolder = nil
        selectedTag = nil
        loadNotes()
    }

    func setSortOption(_ option: SortOption) {
        sortOption = option
        loadNotes()
    }

    func selectFolder(_ folder: Folder) {
        selectedFolder = folder
        filter = .all
        selectedTag = nil
        loadNotes()
    }

    func selectTag(_ tag: Tag) {
        selectedTag = tag
        filter = .all
        selectedFolder = nil
        loadNotes()
    }

    func deleteNote(_ note: Note) {
        do {
            try noteService.deleteNote(note)
            loadNotes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleFavorite(_ note: Note) {
        do {
            try noteService.toggleFavorite(note)
            loadNotes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func togglePin(_ note: Note) {
        do {
            try noteService.togglePin(note)
            loadNotes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func archiveNote(_ note: Note) {
        do {
            try noteService.archiveNote(note)
            loadNotes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
