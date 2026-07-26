import Foundation
import SwiftData

actor SwiftDataStack {
    static let shared = SwiftDataStack()

    private init() {}

    nonisolated var container: ModelContainer {
        get throws {
            let schema = Schema([
                Note.self,
                Folder.self,
                Tag.self,
                NoteBlock.self,
                AppSettings.self
            ])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        }
    }

    nonisolated func createContext() throws -> ModelContext {
        let context = ModelContext(try container)
        context.autosaveEnabled = true
        return context
    }
}
