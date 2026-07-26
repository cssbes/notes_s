import Foundation
import SwiftData

enum SwiftDataStack {
    static let shared = SwiftDataStack()

    static var container: ModelContainer = {
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
        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }()
}
