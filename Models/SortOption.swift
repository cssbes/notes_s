import Foundation

enum SortOption: String, CaseIterable, Identifiable {
    case updatedAtDesc
    case updatedAtAsc
    case createdAtDesc
    case createdAtAsc
    case titleAsc
    case titleDesc

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .updatedAtDesc: return "Recently Updated"
        case .updatedAtAsc: return "Oldest Updated"
        case .createdAtDesc: return "Recently Created"
        case .createdAtAsc: return "Oldest Created"
        case .titleAsc: return "Title A-Z"
        case .titleDesc: return "Title Z-A"
        }
    }

    var systemImage: String {
        switch self {
        case .updatedAtDesc: return "clock.arrow.circlepath"
        case .updatedAtAsc: return "clock.arrow.2.circlepath"
        case .createdAtDesc: return "plus.circle"
        case .createdAtAsc: return "plus.circle.dotted"
        case .titleAsc: return "textformat.sort.ascending"
        case .titleDesc: return "textformat.sort.descending"
        }
    }
}

enum NoteListFilter: String, CaseIterable, Identifiable {
    case all
    case favorites
    case pinned
    case archived
    case trashed

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: return "All Notes"
        case .favorites: return "Favorites"
        case .pinned: return "Pinned"
        case .archived: return "Archived"
        case .trashed: return "Trash"
        }
    }
}
