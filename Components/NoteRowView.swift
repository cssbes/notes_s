import SwiftUI

struct NoteRowView: View {
    let note: Note

    private var dateText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: note.updatedAt, relativeTo: Date())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Text(note.title.isEmpty ? "Untitled" : note.title)
                    .font(.headline)
                    .lineLimit(1)

                Spacer(minLength: 0)

                if note.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                }
            }

            if !note.previewText.isEmpty {
                Text(note.previewText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack(spacing: 12) {
                Label(dateText, systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                if !note.tags.isEmpty {
                    ForEach(note.tags.prefix(3)) { tag in
                        Text(tag.name)
                            .font(.caption2)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: tag.colorHex) ?? .accentColor)
                            .cornerRadius(4)
                    }
                }

                if note.wordCount > 0 {
                    Text("\(note.wordCount) words")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
