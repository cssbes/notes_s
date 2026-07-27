import Foundation

struct NoteTemplate: Identifiable, Codable {
    let id: UUID
    let name: String
    let nameAr: String
    let emoji: String
    let title: String
    let content: String
    let tags: [String]

    init(id: UUID = UUID(), name: String, nameAr: String, emoji: String, title: String, content: String, tags: [String] = []) {
        self.id = id
        self.name = name
        self.nameAr = nameAr
        self.emoji = emoji
        self.title = title
        self.content = content
        self.tags = tags
    }

    static let all: [NoteTemplate] = [
        NoteTemplate(
            name: "Daily Journal", nameAr: "مذكرات يومية", emoji: "📖",
            title: "Journal — ",
            content: "<h1>Today's Entry</h1><p>How was your day?</p><ul><li>What went well?</li><li>What could be better?</li><li>Gratitude</li></ul>",
            tags: ["journal"]
        ),
        NoteTemplate(
            name: "Meeting Notes", nameAr: "ملاحظات اجتماع", emoji: "👔",
            title: "Meeting — ",
            content: "<h1>Meeting Notes</h1><p><b>Date:</b> <br><b>Attendees:</b> <br><b>Topic:</b> </p><h2>Agenda</h2><ol><li></li></ol><h2>Action Items</h2><ul><li>[ ] </li></ul>",
            tags: ["work", "meeting"]
        ),
        NoteTemplate(
            name: "Weekly Plan", nameAr: "خطة أسبوعية", emoji: "📋",
            title: "Weekly Plan — ",
            content: "<h1>This Week</h1><h2>Goals</h2><ol><li></li></ol><h2>Monday</h2><ul><li></li></ul><h2>Tuesday</h2><ul><li></li></ul><h2>Wednesday</h2><ul><li></li></ul><h2>Thursday</h2><ul><li></li></ul><h2>Friday</h2><ul><li></li></ul>",
            tags: ["planning"]
        ),
        NoteTemplate(
            name: "Recipe", nameAr: "وصفة طبخ", emoji: "🍳",
            title: "Recipe — ",
            content: "<h1>Recipe</h1><p><b>Prep Time:</b> <br><b>Cook Time:</b> <br><b>Servings:</b> </p><h2>Ingredients</h2><ul><li>[ ] </li></ul><h2>Instructions</h2><ol><li></li></ol>",
            tags: ["personal"]
        ),
        NoteTemplate(
            name: "Book Notes", nameAr: "ملاحظات كتاب", emoji: "📚",
            title: "Book — ",
            content: "<h1>Book Notes</h1><p><b>Title:</b> <br><b>Author:</b> <br><b>Pages:</b> </p><h2>Key Takeaways</h2><ol><li></li></ol><h2>Quotes</h2><blockquote></blockquote>",
            tags: ["reading"]
        ),
        NoteTemplate(
            name: "Project Planner", nameAr: "مخطط مشروع", emoji: "🚀",
            title: "Project — ",
            content: "<h1>Project Plan</h1><p><b>Start Date:</b> <br><b>Deadline:</b> </p><h2>Milestones</h2><ol><li></li></ol><h2>Tasks</h2><ul><li>[ ] </li></ul>",
            tags: ["work"]
        ),
        NoteTemplate(
            name: "Study Notes", nameAr: "ملاحظات دراسة", emoji: "🎓",
            title: "Study — ",
            content: "<h1>Study Notes</h1><p><b>Subject:</b> <br><b>Topic:</b> </p><h2>Summary</h2><p></p><h2>Key Points</h2><ul><li></li></ul><h2>Questions</h2><ol><li></li></ol>",
            tags: ["study"]
        ),
    ]
}
