import Foundation
import SwiftData

enum SwiftDataStack {
    nonisolated(unsafe) static var container: ModelContainer = {
        do {
            return try ModelContainer(
                for: Note.self, Folder.self, Tag.self, NoteBlock.self, AppSettings.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }()
}
