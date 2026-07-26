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

final class ExportService {

    func exportToMarkdown(_ note: Note) throws -> Data {
        var md = "# \(note.title)\n\n"

        for block in note.blocks.sorted(by: { $0.orderIndex < $1.orderIndex }) {
            switch block.type {
            case .text:
                md += "\(block.content)\n\n"
            case .heading1:
                md += "# \(block.content)\n\n"
            case .heading2:
                md += "## \(block.content)\n\n"
            case .heading3:
                md += "### \(block.content)\n\n"
            case .bulletListItem:
                md += "- \(block.content)\n"
            case .numberedListItem:
                md += "1. \(block.content)\n"
            case .checklistItem:
                let checked = block.isChecked ? "x" : " "
                md += "- [\(checked)] \(block.content)\n"
            case .quote:
                md += "> \(block.content)\n\n"
            case .code:
                md += "```\n\(block.content)\n```\n\n"
            case .image:
                md += "![\(block.content)](\(block.metadata ?? ""))\n\n"
            case .table:
                md += "\(block.content)\n\n"
            case .divider:
                md += "---\n\n"
            }
        }

        md += "\n---\n"
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        md += "Exported from Notes on \(formatter.string(from: Date()))\n"

        guard let data = md.data(using: .utf8) else {
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
            "tags": note.tags.map { $0.name },
            "folder": note.folder?.name ?? ""
        ]

        let data = try JSONSerialization.data(
            withJSONObject: exportDict,
            options: [.prettyPrinted, .sortedKeys]
        )
        return data
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

        return try JSONSerialization.data(
            withJSONObject: exportDict,
            options: [.prettyPrinted, .sortedKeys]
        )
    }
}
