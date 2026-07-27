import Foundation
import SwiftData

enum SwiftDataStack {
    nonisolated(unsafe) static var container: ModelContainer = {
        do {
            let schema = Schema([
                Note.self, Folder.self, Tag.self, NoteBlock.self,
                AppSettings.self, TaskItem.self, NoteAttachment.self
            ])
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .private("iCloud.com.notes.app")
            )
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            let fallback = ModelConfiguration(schema: Schema([
                Note.self, Folder.self, Tag.self, NoteBlock.self,
                AppSettings.self, TaskItem.self, NoteAttachment.self
            ]))
            return try! ModelContainer(for: Schema([
                Note.self, Folder.self, Tag.self, NoteBlock.self,
                AppSettings.self, TaskItem.self, NoteAttachment.self
            ]), configurations: fallback)
        }
    }()
}
