import SwiftUI

struct TagView: View {
    let tag: Tag
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color(hex: tag.colorHex) ?? .blue)
                .frame(width: 8, height: 8)

            Text(tag.name)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            (Color(hex: tag.colorHex) ?? .blue)
                .opacity(isSelected ? 0.15 : 0.08)
        )
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    (Color(hex: tag.colorHex) ?? .blue)
                        .opacity(isSelected ? 0.5 : 0.1),
                    lineWidth: 1
                )
        )
    }
}

struct TagListView: View {
    let tags: [Tag]
    var selectedTag: Tag?
    var onSelect: ((Tag) -> Void)?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags) { tag in
                    Button {
                        onSelect?(tag)
                    } label: {
                        TagView(tag: tag, isSelected: selectedTag?.id == tag.id)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}
