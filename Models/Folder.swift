import Foundation
import SwiftData

@Model
final class Folder {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String
    var createdAt: Date
    var orderIndex: Int

    @Relationship(deleteRule: .cascade) var childFolders: [Folder]
    @Relationship(deleteRule: .nullify) var notes: [Note]
    @Relationship(inverse: \Folder.childFolders) var parentFolder: Folder?

    init(
        name: String,
        icon: String = "folder",
        parentFolder: Folder? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.createdAt = Date()
        self.orderIndex = 0
        self.childFolders = []
        self.notes = []
        self.parentFolder = parentFolder
    }

    var noteCount: Int {
        notes.count { !$0.isTrashed && !$0.isArchived }
    }

    var isRoot: Bool {
        parentFolder == nil
    }
}
