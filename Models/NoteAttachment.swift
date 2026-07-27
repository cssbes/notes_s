import Foundation
import SwiftData
import UIKit

enum AttachmentType: String, Codable {
    case image, drawing, pdf, scannedDocument

    var icon: String {
        switch self {
        case .image: return "photo"
        case .drawing: return "pencil.tip"
        case .pdf: return "doc"
        case .scannedDocument: return "doc.viewfinder"
        }
    }
}

@Model
final class NoteAttachment {
    @Attribute(.unique) var id: UUID
    var typeRaw: String
    var fileName: String
    var data: Data
    var createdAt: Date
    var noteID: UUID

    var type: AttachmentType {
        get { AttachmentType(rawValue: typeRaw) ?? .image }
        set { typeRaw = newValue.rawValue }
    }

    var thumbnail: UIImage? {
        switch type {
        case .image, .scannedDocument:
            return UIImage(data: data)
        case .drawing:
            return nil
        case .pdf:
            return nil
        }
    }

    init(type: AttachmentType, fileName: String, data: Data, noteID: UUID) {
        self.id = UUID()
        self.typeRaw = type.rawValue
        self.fileName = fileName
        self.data = data
        self.createdAt = Date()
        self.noteID = noteID
    }
}
