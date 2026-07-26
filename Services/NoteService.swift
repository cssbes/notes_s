import Foundation
import SwiftData

@MainActor
final class NoteService {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Notes

    func fetchNotes(
        filter: NoteListFilter = .all,
        sort: SortOption = .updatedAtDesc,
        folder: Folder? = nil,
        tag: Tag? = nil
    ) throws -> [Note] {
        let descriptor = FetchDescriptor<Note>(sortBy: [sortDescriptor(for: sort)])
        let allNotes = try context.fetch(descriptor)

        return allNotes.filter { note in
            var matches = true

            switch filter {
            case .all:
                matches = matches && !note.isArchived && !note.isTrashed
            case .favorites:
                matches = matches && note.isFavorite && !note.isTrashed
            case .pinned:
                matches = matches && note.pinnedAt != nil && !note.isTrashed
            case .archived:
                matches = matches && note.isArchived && !note.isTrashed
            case .trashed:
                matches = matches && note.isTrashed
            }

            if let folder {
                matches = matches && note.folder?.id == folder.id
            }

            if let tag {
                matches = matches && note.tags.contains(where: { $0.id == tag.id })
            }

            return matches
        }
    }

    func fetchNote(by id: UUID) throws -> Note? {
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }

    func createNote(title: String = "", folder: Folder? = nil) throws -> Note {
        let note = Note(title: title, folder: folder)
        context.insert(note)
        try context.save()
        return note
    }

    func updateNote(_ note: Note) throws {
        note.updatedAt = Date()
        note.updateStatistics()
        try context.save()
    }

    func deleteNote(_ note: Note) throws {
        if note.isTrashed {
            context.delete(note)
        } else {
            note.isTrashed = true
            note.trashedAt = Date()
            try context.save()
        }
    }

    func permanentlyDeleteNote(_ note: Note) throws {
        context.delete(note)
        try context.save()
    }

    func restoreNote(_ note: Note) throws {
        note.isTrashed = false
        note.trashedAt = nil
        try context.save()
    }

    func toggleFavorite(_ note: Note) throws {
        note.isFavorite.toggle()
        try context.save()
    }

    func togglePin(_ note: Note) throws {
        note.pinnedAt = note.isPinned ? nil : Date()
        try context.save()
    }

    func archiveNote(_ note: Note) throws {
        note.isArchived = true
        try context.save()
    }

    func unarchiveNote(_ note: Note) throws {
        note.isArchived = false
        try context.save()
    }

    // MARK: - Folders

    func fetchFolders() throws -> [Folder] {
        let descriptor = FetchDescriptor<Folder>(sortBy: [SortDescriptor(\.orderIndex)])
        return try context.fetch(descriptor)
    }

    func fetchRootFolders() throws -> [Folder] {
        let descriptor = FetchDescriptor<Folder>(
            predicate: #Predicate { $0.parentFolder == nil },
            sortBy: [SortDescriptor(\.orderIndex)]
        )
        return try context.fetch(descriptor)
    }

    func createFolder(name: String, icon: String = "folder", parent: Folder? = nil) throws -> Folder {
        let folder = Folder(name: name, icon: icon, parentFolder: parent)
        context.insert(folder)
        try context.save()
        return folder
    }

    func deleteFolder(_ folder: Folder) throws {
        context.delete(folder)
        try context.save()
    }

    // MARK: - Tags

    func fetchTags() throws -> [Tag] {
        let descriptor = FetchDescriptor<Tag>(sortBy: [SortDescriptor(\.name)])
        return try context.fetch(descriptor)
    }

    func createTag(name: String, colorHex: String = "#007AFF") throws -> Tag {
        let tag = Tag(name: name, colorHex: colorHex)
        context.insert(tag)
        try context.save()
        return tag
    }

    func deleteTag(_ tag: Tag) throws {
        context.delete(tag)
        try context.save()
    }

    // MARK: - Blocks

    func addBlock(to note: Note, type: BlockType = .text, content: String = "") throws -> NoteBlock {
        let block = NoteBlock(type: type, content: content, orderIndex: note.blocks.count)
        note.blocks.append(block)
        context.insert(block)
        try context.save()
        return block
    }

    func updateBlock(_ block: NoteBlock) throws {
        try context.save()
    }

    func deleteBlock(_ block: NoteBlock) throws {
        context.delete(block)
        try context.save()
    }

    func reorderBlocks(in note: Note, from source: IndexSet, to destination: Int) throws {
        note.blocks.move(fromOffsets: source, toOffset: destination)
        for (index, block) in note.blocks.enumerated() {
            block.orderIndex = index
        }
        try context.save()
    }

    // MARK: - Empty Trash

    func emptyTrash() throws {
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate { $0.isTrashed }
        )
        let trashedNotes = try context.fetch(descriptor)
        for note in trashedNotes {
            context.delete(note)
        }
        try context.save()
    }

    // MARK: - Helpers

    private func sortDescriptor(for sort: SortOption) -> SortDescriptor<Note> {
        switch sort {
        case .updatedAtDesc: return SortDescriptor(\.updatedAt, order: .reverse)
        case .updatedAtAsc: return SortDescriptor(\.updatedAt, order: .forward)
        case .createdAtDesc: return SortDescriptor(\.createdAt, order: .reverse)
        case .createdAtAsc: return SortDescriptor(\.createdAt, order: .forward)
        case .titleAsc: return SortDescriptor(\.title, order: .forward)
        case .titleDesc: return SortDescriptor(\.title, order: .reverse)
        }
    }
}
