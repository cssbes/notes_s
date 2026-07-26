import Foundation
import SwiftData

enum BackupError: LocalizedError {
    case fileNotFound
    case invalidFormat
    case writeFailed
    case readFailed

    var errorDescription: String? {
        switch self {
        case .fileNotFound: return "Backup file not found."
        case .invalidFormat: return "Backup file has an invalid format."
        case .writeFailed: return "Failed to write backup file."
        case .readFailed: return "Failed to read backup file."
        }
    }
}

// MARK: - Backup DTOs (Codable, no relationships)

private struct BackupNote: Codable {
    let id: UUID
    let title: String
    let content: String
    let createdAt: Date
    let updatedAt: Date
    let isFavorite: Bool
    let isArchived: Bool
    let isTrashed: Bool
    let folderID: UUID?
    let tagIDs: [UUID]
}

private struct BackupFolder: Codable {
    let id: UUID
    let name: String
    let icon: String
    let createdAt: Date
    let parentFolderID: UUID?
}

private struct BackupTag: Codable {
    let id: UUID
    let name: String
    let colorHex: String
}

private struct BackupData: Codable {
    let app: String
    let version: String
    let exportedAt: Date
    let notes: [BackupNote]
    let folders: [BackupFolder]
    let tags: [BackupTag]
}

@MainActor
final class BackupService {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    private var backupURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("notes_backup.json")
    }

    func createBackup() throws -> URL {
        let noteDescriptor = FetchDescriptor<Note>()
        let folderDescriptor = FetchDescriptor<Folder>()
        let tagDescriptor = FetchDescriptor<Tag>()

        let notes = try context.fetch(noteDescriptor)
        let folders = try context.fetch(folderDescriptor)
        let tags = try context.fetch(tagDescriptor)

        let backupNotes = notes.map { note in
            BackupNote(
                id: note.id,
                title: note.title,
                content: note.content,
                createdAt: note.createdAt,
                updatedAt: note.updatedAt,
                isFavorite: note.isFavorite,
                isArchived: note.isArchived,
                isTrashed: note.isTrashed,
                folderID: note.folder?.id,
                tagIDs: note.tags.map(\.id)
            )
        }

        let backupFolders = folders.map { folder in
            BackupFolder(
                id: folder.id,
                name: folder.name,
                icon: folder.icon,
                createdAt: folder.createdAt,
                parentFolderID: folder.parentFolder?.id
            )
        }

        let backupTags = tags.map { tag in
            BackupTag(
                id: tag.id,
                name: tag.name,
                colorHex: tag.colorHex
            )
        }

        let backupData = BackupData(
            app: "Notes",
            version: "1.0",
            exportedAt: Date(),
            notes: backupNotes,
            folders: backupFolders,
            tags: backupTags
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(backupData)
        try data.write(to: backupURL, options: [.atomic, .completeFileProtectionUnlessOpen])

        return backupURL
    }

    func restoreBackup(from url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw BackupError.fileNotFound
        }

        let data = try Data(contentsOf: url)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let backupData = try? decoder.decode(BackupData.self, from: data) else {
            throw BackupError.invalidFormat
        }

        var folderMap: [UUID: Folder] = [:]
        var tagMap: [UUID: Tag] = [:]

        for backupTag in backupData.tags {
            let existing: [Tag] = try context.fetch(
                FetchDescriptor<Tag>(predicate: #Predicate { $0.id == backupTag.id })
            )
            if existing.isEmpty {
                let tag = Tag(name: backupTag.name, colorHex: backupTag.colorHex)
                context.insert(tag)
                tagMap[backupTag.id] = tag
            }
        }

        for backupFolder in backupData.folders {
            let existing: [Folder] = try context.fetch(
                FetchDescriptor<Folder>(predicate: #Predicate { $0.id == backupFolder.id })
            )
            if existing.isEmpty {
                let folder = Folder(name: backupFolder.name, icon: backupFolder.icon)
                context.insert(folder)
                folderMap[backupFolder.id] = folder
            }
        }

        for backupFolder in backupData.folders {
            guard let folder = folderMap[backupFolder.id],
                  let parentID = backupFolder.parentFolderID,
                  let parent = folderMap[parentID] else { continue }
            folder.parentFolder = parent
        }

        for backupNote in backupData.notes {
            let existing: [Note] = try context.fetch(
                FetchDescriptor<Note>(predicate: #Predicate { $0.id == backupNote.id })
            )
            if existing.isEmpty {
                let note = Note(title: backupNote.title, content: backupNote.content)
                note.createdAt = backupNote.createdAt
                note.updatedAt = backupNote.updatedAt
                note.isFavorite = backupNote.isFavorite
                note.isArchived = backupNote.isArchived
                note.isTrashed = backupNote.isTrashed
                note.folder = folderMap[backupNote.folderID ?? UUID()]
                note.tags = backupNote.tagIDs.compactMap { tagMap[$0] }
                context.insert(note)
            }
        }

        try context.save()
    }

    func getBackupCreationDate() -> Date? {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: backupURL.path) else {
            return nil
        }
        return attributes[.creationDate] as? Date
    }

    func backupExists() -> Bool {
        FileManager.default.fileExists(atPath: backupURL.path)
    }
}
