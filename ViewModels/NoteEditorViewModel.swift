import Foundation
import SwiftData
import Observation
import UniformTypeIdentifiers

@MainActor
@Observable
final class NoteEditorViewModel {
    private let noteService: NoteService
    private let exportService: ExportService

    var note: Note
    var title: String
    var content: String
    var blocks: [NoteBlock]
    var isNew: Bool
    var isSaving = false
    var errorMessage: String?
    var showDeleteConfirmation = false
    var showExportPicker = false
    var showFolderPicker = false
    var showEmojiPicker = false
    var showColorPicker = false
    var showTemplatePicker = false
    var showDocumentScanner = false
    var showAttachmentPicker = false
    var showHijriDate = false
    var attachments: [NoteAttachment] = []

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
        self.exportService = ExportService()

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

        loadAttachments()

        undoStack = [content]
    }

    private func loadAttachments() {
        let nid = note.id
        let desc = FetchDescriptor<NoteAttachment>(predicate: #Predicate { $0.noteID == nid })
        attachments = (try? noteService.context.fetch(desc)) ?? []
    }

    func addAttachment(type: AttachmentType, data: Data, fileName: String) {
        let att = NoteAttachment(type: type, fileName: fileName, data: data, noteID: note.id)
        noteService.context.insert(att)
        attachments.append(att)
        if !note.title.isEmpty && note.content.isEmpty {
            note.content = "<p>\(fileName)</p>"
        }
        try? noteService.context.save()
    }

    func deleteAttachment(_ attachment: NoteAttachment) {
        noteService.context.delete(attachment)
        attachments.removeAll { $0.id == attachment.id }
        try? noteService.context.save()
    }

    func applyTemplate(_ template: NoteTemplate) {
        title = template.title
        content = template.content
        pushUndo()
    }

    func insertHijriDate() {
        let hijri = Date().hijriFull
        let greg = Date().gregorianFull
        content += "<p><b>\(greg)</b><br>\(hijri)</p>"
        pushUndo()
    }

    func applySmartTags() {
        let suggested = SmartTagService.suggestTags(for: content, title: title)
        for tagName in suggested {
            if !note.tags.contains(where: { $0.name == tagName }) {
                if let tag = try? noteService.createTag(name: tagName) {
                    note.tags.append(tag)
                }
            }
        }
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

    func duplicateNote() {
        let copy = note.duplicate()
        noteService.context.insert(copy)
        do {
            try noteService.context.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func moveToFolder(_ folder: Folder?) {
        note.folder = folder
        do {
            try noteService.updateNote(note)
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

    func updateStatistics() {
        note.updateStatistics()
    }

    // MARK: - Export

    func exportMarkdown() -> Data? {
        try? exportService.exportToMarkdown(note)
    }

    func exportPlainText() -> Data? {
        try? exportService.exportToPlainText(note)
    }

    func exportJSON() -> Data? {
        try? exportService.exportToJSON(note)
    }
}
