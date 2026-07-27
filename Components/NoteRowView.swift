import SwiftUI

struct NoteRowView: View {
    let note: Note

    private var dateText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: note.updatedAt, relativeTo: Date())
    }

    var body: some View {
        HStack(spacing: 14) {
            if !note.emoji.isEmpty {
                Text(note.emoji)
                    .font(.title2)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(note.displayTitle)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.themeText)
                        .lineLimit(1)
                    Spacer()
                    if note.isFavorite {
                        Image(systemName: "star.fill").font(.caption2).foregroundStyle(.yellow)
                    }
                    if note.isPinned {
                        Image(systemName: "pin.fill").font(.caption2).foregroundStyle(Color.themeSubtle)
                    }
                }

                if !note.previewText.isEmpty {
                    Text(note.previewText)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(Color.themeSubtle)
                        .lineLimit(2)
                }

                HStack(spacing: 10) {
                    Text(dateText)
                        .font(.caption)
                        .foregroundStyle(Color.themeSubtle)

                    if note.wordCount > 0 {
                        Text("\(note.wordCount)w")
                            .font(.caption)
                            .foregroundStyle(Color.themeSubtle)
                    }

                    if !note.tags.isEmpty {
                        ForEach(note.tags.prefix(2)) { tag in
                            Text(tag.name)
                                .font(.caption2)
                                .foregroundStyle(Color.themeAccent)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Color.themeAccent.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .contentShape(Rectangle())
    }
}
