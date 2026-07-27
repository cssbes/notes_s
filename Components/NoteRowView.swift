import SwiftUI

struct NoteRowView: View {
    let note: Note

    private var dateText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: note.updatedAt, relativeTo: Date())
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(note.displayTitle)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.nText)
                        .lineLimit(1)
                    Spacer()
                    if note.isPinned {
                        Image(systemName: "pin.fill").font(.system(size: 8)).foregroundStyle(Color.nSecondary)
                    }
                    if note.isFavorite {
                        Image(systemName: "star.fill").font(.system(size: 8)).foregroundStyle(.yellow)
                    }
                }
                if !note.previewText.isEmpty {
                    Text(note.previewText)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.nSecondary)
                        .lineLimit(2)
                }
                HStack(spacing: 10) {
                    Text(dateText).font(.system(size: 11)).foregroundStyle(Color.nTertiary)
                    if note.wordCount > 0 {
                        Text("\(note.wordCount) words").font(.system(size: 11)).foregroundStyle(Color.nTertiary)
                    }
                    if !note.tags.isEmpty {
                        ForEach(note.tags.prefix(2)) { tag in
                            Text(tag.name).font(.system(size: 10)).foregroundStyle(.white)
                                .padding(.horizontal, 5).padding(.vertical, 1)
                                .background(Color(hex: tag.colorHex) ?? .blue)
                                .cornerRadius(3)
                        }
                    }
                }
            }
        }
        .contentShape(Rectangle())
    }
}
