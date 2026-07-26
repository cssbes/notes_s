import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class NoteEditorViewModel {
    private let noteService: NoteService

    var note: Note
    var title: String
    var content: String
    var blocks: [NoteBlock]
    var isNew: Bool
    var isSaving = false
    var errorMessage: String?
    var showDeleteConfirmation = false

    var wordCount: Int { note.wordCount }
    var characterCount: Int { note.characterCount }
    var readingTime: Int { note.readingTime }

    var canUndo: Bool { undoStack.count > 1 }
    var canRedo: Bool { redoStack.count > 0 }

    private var undoStack: [String] = []
    private var redoStack: [String] = []
    private var lastSavedContent: String = ""
    private var autoSaveTask: Task<Void, Never>?

    init(noteService: NoteService, note: Note? = nil) {
        self.noteService = noteService

        if let existingNote = note {
            self.note = existingNote
            self.title = existingNote.title
            self.content = existingNote.content
            self.blocks = existingNote.blocks.sorted(by: { $0.orderIndex < $1.orderIndex })
            self.isNew = false
            self.lastSavedContent = existingNote.content
        } else {
            let newNote = Note()
            self.note = newNote
            self.title = ""
            self.content = ""
            self.blocks = []
            self.isNew = true
            self.lastSavedContent = ""
        }

        undoStack = [content]
    }

    func save() {
        isSaving = true
        errorMessage = nil

        note.title = title
        note.content = content

        do {
            if isNew {
                noteService.context.insert(note)
            }
            try noteService.updateNote(note)
            isNew = false
            lastSavedContent = content
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }

    func autoSave() {
        guard content != lastSavedContent else { return }

        autoSaveTask?.cancel()
        autoSaveTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(1.5))
            guard let self, !Task.isCancelled else { return }
            self.save()
        }
    }

    func deleteNote() {
        do {
            try noteService.deleteNote(note)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleFavorite() {
        do {
            try noteService.toggleFavorite(note)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func togglePin() {
        do {
            try noteService.togglePin(note)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addBlock(type: BlockType = .text) {
        let block = NoteBlock(type: type, content: "", orderIndex: blocks.count)
        blocks.append(block)
        note.blocks.append(block)
        noteService.context.insert(block)
    }

    func removeBlock(at index: Int) {
        guard index < blocks.count else { return }
        let block = blocks[index]
        blocks.remove(at: index)
        noteService.context.delete(block)
        updateBlockOrder()
    }

    func updateBlock(_ block: NoteBlock, content: String) {
        block.content = content
        self.content = blocks.map { $0.content }.joined(separator: "\n")
        pushUndo()
    }

    private func updateBlockOrder() {
        for (index, block) in blocks.enumerated() {
            block.orderIndex = index
        }
    }

    // MARK: - Undo/Redo

    func pushUndo() {
        redoStack.removeAll()
        if undoStack.last != content {
            undoStack.append(content)
            if undoStack.count > 50 { undoStack.removeFirst() }
        }
    }

    func undo() {
        guard canUndo else { return }
        redoStack.append(undoStack.removeLast())
        content = undoStack.last ?? ""
    }

    func redo() {
        guard canRedo else { return }
        let state = redoStack.removeLast()
        undoStack.append(state)
        content = state
    }

    // MARK: - Statistics

    func updateStatistics() {
        note.updateStatistics()
    }
}
