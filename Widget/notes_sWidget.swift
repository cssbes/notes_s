import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> NotesEntry {
        NotesEntry(date: Date(), noteCount: 0, taskCount: 0, recentNote: "Sample Note")
    }

    func getSnapshot(in context: Context, completion: @escaping (NotesEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NotesEntry>) -> Void) {
        let entry = loadEntry()
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func loadEntry() -> NotesEntry {
        guard let context = try? ModelContainer(for: Note.self, TaskItem.self).mainContext else {
            return NotesEntry(date: Date(), noteCount: 0, taskCount: 0, recentNote: "Open app")
        }
        let noteCount = (try? context.fetchCount(FetchDescriptor<Note>())) ?? 0
        let taskCount = (try? context.fetchCount(FetchDescriptor<TaskItem>(predicate: #Predicate { !$0.isCompleted }))) ?? 0
        let notes = (try? context.fetch(FetchDescriptor<Note>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]))) ?? []
        let recent = notes.first?.title ?? "No notes"
        return NotesEntry(date: Date(), noteCount: noteCount, taskCount: taskCount, recentNote: recent)
    }
}

struct NotesEntry: TimelineEntry {
    let date: Date
    let noteCount: Int
    let taskCount: Int
    let recentNote: String
}

struct notes_sWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "note.text").font(.caption).foregroundStyle(.blue)
                Text("Notes").font(.headline).fontWeight(.bold)
            }
            Divider()
            HStack {
                Image(systemName: "note.text").font(.caption).foregroundStyle(.secondary)
                Text("\(entry.noteCount) notes")
                Spacer()
            }
            HStack {
                Image(systemName: "checklist").font(.caption).foregroundStyle(.secondary)
                Text("\(entry.taskCount) tasks")
                Spacer()
            }
            if !entry.recentNote.isEmpty {
                Divider()
                Text(entry.recentNote).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding()
        .containerBackground(.background, for: .widget)
    }
}

struct notes_sWidget: Widget {
    let kind: String = "notes_sWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            notes_sWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Notes Overview")
        .description("See your note and task counts.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
