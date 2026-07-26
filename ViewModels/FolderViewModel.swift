import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class FolderViewModel {
    private let noteService: NoteService

    var folders: [Folder] = []
    var isLoading = false
    var errorMessage: String?
    var showCreateSheet = false
    var newFolderName = ""
    var selectedParentFolder: Folder?

    init(noteService: NoteService) {
        self.noteService = noteService
    }

    func loadFolders() {
        isLoading = true
        errorMessage = nil

        do {
            folders = try noteService.fetchRootFolders()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func createFolder() {
        let name = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        do {
            _ = try noteService.createFolder(name: name, parent: selectedParentFolder)
            newFolderName = ""
            selectedParentFolder = nil
            showCreateSheet = false
            loadFolders()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteFolder(_ folder: Folder) {
        do {
            try noteService.deleteFolder(folder)
            loadFolders()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func childFolders(for folder: Folder) -> [Folder] {
        folder.childFolders.sorted { $0.orderIndex < $1.orderIndex }
    }
}
