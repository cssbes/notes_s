import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class HomeViewModel {
    private let noteService: NoteService

    var recentNotes: [Note] = []
    var pinnedNotes: [Note] = []
    var favoriteNotes: [Note] = []
    var folders: [Folder] = []
    var tags: [Tag] = []
    var isLoading = false
    var errorMessage: String?

    var totalNotes: Int { recentNotes.count }
    var totalFolders: Int { folders.count }
    var totalTags: Int { tags.count }

    init(noteService: NoteService) {
        self.noteService = noteService
    }

    func loadData() {
        isLoading = true
        errorMessage = nil

        do {
            recentNotes = try noteService.fetchNotes(sort: .updatedAtDesc)
            pinnedNotes = try noteService.fetchNotes(filter: .pinned, sort: .updatedAtDesc)
            favoriteNotes = try noteService.fetchNotes(filter: .favorites, sort: .updatedAtDesc)
            folders = try noteService.fetchRootFolders()
            tags = try noteService.fetchTags()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func deleteNote(_ note: Note) {
        do {
            try noteService.deleteNote(note)
            loadData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleFavorite(_ note: Note) {
        do {
            try noteService.toggleFavorite(note)
            loadData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func togglePin(_ note: Note) {
        do {
            try noteService.togglePin(note)
            loadData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createFolder(name: String) {
        do {
            _ = try noteService.createFolder(name: name)
            loadData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteFolder(_ folder: Folder) {
        do {
            try noteService.deleteFolder(folder)
            loadData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
