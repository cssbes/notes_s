import Foundation
import SwiftData

enum BlockType: String, Codable, CaseIterable, Identifiable {
    case text
    case heading1
    case heading2
    case heading3
    case bulletListItem
    case numberedListItem
    case checklistItem
    case quote
    case code
    case image
    case table
    case divider

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .text: return "Text"
        case .heading1: return "Heading 1"
        case .heading2: return "Heading 2"
        case .heading3: return "Heading 3"
        case .bulletListItem: return "Bullet List"
        case .numberedListItem: return "Numbered List"
        case .checklistItem: return "Checklist"
        case .quote: return "Quote"
        case .code: return "Code"
        case .image: return "Image"
        case .table: return "Table"
        case .divider: return "Divider"
        }
    }

    var systemImage: String {
        switch self {
        case .text: return "text.alignleft"
        case .heading1: return "textformat.size.larger"
        case .heading2: return "textformat.size"
        case .heading3: return "textformat.size.smaller"
        case .bulletListItem: return "list.bullet"
        case .numberedListItem: return "list.number"
        case .checklistItem: return "checklist"
        case .quote: return "quote.bubble"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .image: return "photo"
        case .table: return "tablecells"
        case .divider: return "minus"
        }
    }
}

@Model
final class NoteBlock {
    @Attribute(.unique) var id: UUID
    var typeRawValue: String
    var content: String
    var orderIndex: Int
    var isChecked: Bool
    var metadata: String?

    var note: Note?

    var type: BlockType {
        get { BlockType(rawValue: typeRawValue) ?? .text }
        set { typeRawValue = newValue.rawValue }
    }

    init(
        type: BlockType = .text,
        content: String = "",
        orderIndex: Int = 0,
        isChecked: Bool = false
    ) {
        self.id = UUID()
        self.typeRawValue = type.rawValue
        self.content = content
        self.orderIndex = orderIndex
        self.isChecked = isChecked
    }
}
