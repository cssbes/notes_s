import Foundation
import UniformTypeIdentifiers

enum ExportError: LocalizedError {
    case encodingFailed
    case exportFailed(String)

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode the note for export."
        case .exportFailed(let detail):
            return "Export failed: \(detail)"
        }
    }
}

@MainActor final class ExportService {

    func exportToMarkdown(_ note: Note) throws -> Data {
        var md = "# \(note.title)\n\n"
        md += parseContentToMarkdown(note.content)
        md += "\n---\n"
        md += "Exported from Notes on \(Date().formatted(Date.FormatStyle(date: .long, time: .standard)))\n"
        guard let data = md.data(using: .utf8) else {
            throw ExportError.encodingFailed
        }
        return data
    }

    func exportToPlainText(_ note: Note) throws -> Data {
        let plain = note.content.strippingHTML
        let text = "\(note.title)\n\n\(plain)\n\n---\nExported from Notes"
        guard let data = text.data(using: .utf8) else {
            throw ExportError.encodingFailed
        }
        return data
    }

    func exportToJSON(_ note: Note) throws -> Data {
        let exportDict: [String: Any] = [
            "id": note.id.uuidString,
            "title": note.title,
            "content": note.content,
            "createdAt": note.createdAt.timeIntervalSince1970,
            "updatedAt": note.updatedAt.timeIntervalSince1970,
            "isFavorite": note.isFavorite,
            "isArchived": note.isArchived,
            "isTrashed": note.isTrashed,
            "emoji": note.emoji,
            "colorHex": note.colorHex,
            "tags": note.tags.map { $0.name },
            "folder": note.folder?.name ?? "",
            "wordCount": note.wordCount,
            "characterCount": note.characterCount,
            "readingTime": note.readingTime
        ]
        return try JSONSerialization.data(withJSONObject: exportDict, options: [.prettyPrinted, .sortedKeys])
    }

    func exportAllNotes(_ notes: [Note]) throws -> Data {
        var allData: [[String: Any]] = []
        for note in notes {
            let dict: [String: Any] = [
                "id": note.id.uuidString,
                "title": note.title,
                "content": note.content,
                "createdAt": note.createdAt.timeIntervalSince1970,
                "updatedAt": note.updatedAt.timeIntervalSince1970,
                "isFavorite": note.isFavorite,
                "isArchived": note.isArchived,
                "isTrashed": note.isTrashed,
                "emoji": note.emoji,
                "colorHex": note.colorHex,
                "tags": note.tags.map { $0.name },
                "folder": note.folder?.name ?? ""
            ]
            allData.append(dict)
        }
        let exportDict: [String: Any] = [
            "app": "Notes",
            "version": "1.0",
            "exportedAt": Date().timeIntervalSince1970,
            "notes": allData
        ]
        return try JSONSerialization.data(withJSONObject: exportDict, options: [.prettyPrinted, .sortedKeys])
    }

    private func parseContentToMarkdown(_ html: String) -> String {
        let plain = html.strippingHTML
        return plain + "\n\n"
    }
}
