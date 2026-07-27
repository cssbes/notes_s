import Foundation
import SwiftData

enum SwiftDataStack {
    nonisolated(unsafe) static var container: ModelContainer = {
        let schema = Schema([
            Note.self, Folder.self, Tag.self, NoteBlock.self,
            AppSettings.self, TaskItem.self, NoteAttachment.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: config)
    }()
}
