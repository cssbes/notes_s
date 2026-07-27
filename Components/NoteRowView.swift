import SwiftUI

struct NoteRowView: View {
    let note: Note

    private var dateText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: note.updatedAt, relativeTo: Date())
    }

    var body: some View {
        HStack(spacing: 12) {
            if !note.emoji.isEmpty {
                Text(note.emoji)
                    .font(.title)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    if note.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Text(note.displayTitle)
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

                HStack(spacing: 8) {
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
                                .background(Color(hex: tag.colorHex) ?? .blue)
                                .cornerRadius(4)
                        }
                    }

                    if note.wordCount > 0 {
                        Text("\(note.wordCount) words")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    if note.readingTime > 0 {
                        Text("\(note.readingTime) min read")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .padding(.leading, note.colorHex.isEmpty ? 0 : 4)
        .overlay(
            Rectangle()
                .fill(Color(hex: note.colorHex) ?? .clear)
                .frame(width: 4)
                .cornerRadius(2),
            alignment: .leading
        )
        .contentShape(Rectangle())
    }
}
