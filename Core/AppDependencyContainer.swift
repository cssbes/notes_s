import Foundation
import SwiftData

@MainActor
final class AppDependencyContainer {
    let context: ModelContext
    let noteService: NoteService
    let searchService: SearchService
    let exportService: ExportService
    let backupService: BackupService

    init() {
        let container = SwiftDataStack.container
        let context = ModelContext(container)
        context.autosaveEnabled = true
        self.context = context

        self.noteService = NoteService(context: context)
        self.searchService = SearchService(context: context)
        self.exportService = ExportService()
        self.backupService = BackupService(context: context)
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(noteService: noteService)
    }

    func makeNoteListViewModel() -> NoteListViewModel {
        NoteListViewModel(noteService: noteService)
    }

    func makeNoteEditorViewModel(note: Note? = nil) -> NoteEditorViewModel {
        NoteEditorViewModel(noteService: noteService, note: note)
    }

    func makeFolderViewModel() -> FolderViewModel {
        FolderViewModel(noteService: noteService)
    }

    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(searchService: searchService)
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(noteService: noteService, backupService: backupService)
    }

    func makeTrashViewModel() -> TrashViewModel {
        TrashViewModel(noteService: noteService)
    }

    func makeArchiveViewModel() -> ArchiveViewModel {
        ArchiveViewModel(noteService: noteService)
    }
}
