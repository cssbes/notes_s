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
    var recentlyEditedNotes: [Note] = []
    var folders: [Folder] = []
    var tags: [Tag] = []
    var isLoading = false
    var errorMessage: String?
    var searchQuery = ""
    var searchResults: [Note] = []

    var totalNotes: Int { recentNotes.count }
    var totalFolders: Int { folders.count }
    var totalTags: Int { tags.count }
    var totalPinned: Int { pinnedNotes.count }
    var totalFavorites: Int { favoriteNotes.count }
    var totalWords: Int { recentNotes.reduce(0) { $0 + $1.wordCount } }

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
            recentlyEditedNotes = try noteService.fetchNotes(sort: .updatedAtDesc)
            folders = try noteService.fetchRootFolders()
            tags = try noteService.fetchTags()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func search() {
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        do {
            let allNotes = try noteService.fetchNotes(sort: .updatedAtDesc)
            let q = searchQuery.lowercased()
            searchResults = allNotes.filter {
                $0.title.lowercased().contains(q) ||
                $0.content.lowercased().contains(q) ||
                $0.tags.contains { $0.name.lowercased().contains(q) } ||
                $0.folder?.name.lowercased().contains(q) == true
            }
        } catch {
            searchResults = []
        }
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
