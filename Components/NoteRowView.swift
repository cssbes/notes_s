import SwiftUI

struct NoteRowView: View {
    let note: Note

    private var dateText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: note.updatedAt, relativeTo: Date())
    }

    private var accentColor: Color {
        Color(hex: note.colorHex) ?? .blue
    }

    var body: some View {
        HStack(spacing: 14) {
            if !note.emoji.isEmpty {
                Text(note.emoji)
                    .font(.title2)
                    .frame(width: 36, height: 36)
                    .background(accentColor.opacity(0.1))
                    .cornerRadius(10)
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

                HStack(spacing: 10) {
                    Label(dateText, systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    if !note.tags.isEmpty {
                        ForEach(note.tags.prefix(3)) { tag in
                            Text(tag.name)
                                .font(.caption2)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(Color(hex: tag.colorHex) ?? .blue)
                                .cornerRadius(5)
                        }
                    }

                    if note.wordCount > 0 {
                        Label("\(note.wordCount) words", systemImage: "text.word.count")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.leading, 8)
        .overlay(
            Rectangle()
                .fill(accentColor)
                .frame(width: 4)
                .cornerRadius(2),
            alignment: .leading
        )
        .contentShape(Rectangle())
    }
}
