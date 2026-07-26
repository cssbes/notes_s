import SwiftUI

struct BlockView: View {
    let block: NoteBlock
    var isEditing: Bool = false
    var onContentChange: ((String) -> Void)?

    var body: some View {
        switch block.type {
        case .text:
            TextBlockView(content: block.content, isEditing: isEditing, onChange: onContentChange)
        case .heading1:
            HeadingBlockView(content: block.content, level: 1, isEditing: isEditing, onChange: onContentChange)
        case .heading2:
            HeadingBlockView(content: block.content, level: 2, isEditing: isEditing, onChange: onContentChange)
        case .heading3:
            HeadingBlockView(content: block.content, level: 3, isEditing: isEditing, onChange: onContentChange)
        case .bulletListItem:
            BulletListItemView(content: block.content, isEditing: isEditing, onChange: onContentChange)
        case .numberedListItem:
            NumberedListItemView(content: block.content, isEditing: isEditing, onChange: onContentChange)
        case .checklistItem:
            ChecklistBlockView(block: block, isEditing: isEditing, onChange: onContentChange)
        case .quote:
            QuoteBlockView(content: block.content, isEditing: isEditing, onChange: onContentChange)
        case .code:
            CodeBlockView(content: block.content, isEditing: isEditing, onChange: onContentChange)
        case .image:
            ImageBlockView(block: block)
        case .table:
            TableBlockView(content: block.content, isEditing: isEditing, onChange: onContentChange)
        case .divider:
            DividerBlockView()
        }
    }
}

// MARK: - Subviews

struct TextBlockView: View {
    let content: String
    var isEditing: Bool
    var onChange: ((String) -> Void)?

    var body: some View {
        if isEditing {
            TextField("Type something...", text: Binding(
                get: { content },
                set: { onChange?($0) }
            ))
            .textFieldStyle(.plain)
            .font(.body)
        } else {
            Text(content)
                .font(.body)
        }
    }
}

struct HeadingBlockView: View {
    let content: String
    let level: Int
    var isEditing: Bool
    var onChange: ((String) -> Void)?

    private var fontSize: CGFloat {
        switch level {
        case 1: return 28
        case 2: return 22
        case 3: return 18
        default: return 16
        }
    }

    private var fontDesign: Font {
        switch level {
        case 1: return .largeTitle
        case 2: return .title2
        case 3: return .title3
        default: return .body
        }
    }

    var body: some View {
        if isEditing {
            TextField("Heading \(level)...", text: Binding(
                get: { content },
                set: { onChange?($0) }
            ))
            .textFieldStyle(.plain)
            .font(fontDesign)
            .fontWeight(.bold)
        } else {
            Text(content)
                .font(fontDesign)
                .fontWeight(.bold)
        }
    }
}

struct BulletListItemView: View {
    let content: String
    var isEditing: Bool
    var onChange: ((String) -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\u{2022}")
                .font(.body)
            if isEditing {
                TextField("List item...", text: Binding(
                    get: { content },
                    set: { onChange?($0) }
                ))
                .textFieldStyle(.plain)
                .font(.body)
            } else {
                Text(content)
                    .font(.body)
            }
        }
    }
}

struct NumberedListItemView: View {
    let content: String
    var isEditing: Bool
    var onChange: ((String) -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("1.")
                .font(.body)
                .foregroundStyle(.secondary)
            if isEditing {
                TextField("List item...", text: Binding(
                    get: { content },
                    set: { onChange?($0) }
                ))
                .textFieldStyle(.plain)
                .font(.body)
            } else {
                Text(content)
                    .font(.body)
            }
        }
    }
}

struct ChecklistBlockView: View {
    let block: NoteBlock
    var isEditing: Bool
    var onChange: ((String) -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Button {
            } label: {
                Image(systemName: block.isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(block.isChecked ? .tint : .secondary)
                    .font(.body)
            }
            .buttonStyle(.plain)

            if isEditing {
                TextField("Checklist item...", text: Binding(
                    get: { block.content },
                    set: { onChange?($0) }
                ))
                .textFieldStyle(.plain)
                .font(.body)
                .strikethrough(block.isChecked)
                .foregroundStyle(block.isChecked ? .secondary : .primary)
            } else {
                Text(block.content)
                    .font(.body)
                    .strikethrough(block.isChecked)
                    .foregroundStyle(block.isChecked ? .secondary : .primary)
            }
        }
    }
}

struct QuoteBlockView: View {
    let content: String
    var isEditing: Bool
    var onChange: ((String) -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Rectangle()
                .fill(.tint)
                .frame(width: 3)
                .cornerRadius(1.5)

            if isEditing {
                TextField("Quote...", text: Binding(
                    get: { content },
                    set: { onChange?($0) }
                ))
                .textFieldStyle(.plain)
                .font(.body.italic())
                .padding(.leading, 12)
            } else {
                Text(content)
                    .font(.body.italic())
                    .padding(.leading, 12)
            }
        }
    }
}

struct CodeBlockView: View {
    let content: String
    var isEditing: Bool
    var onChange: ((String) -> Void)?

    var body: some View {
        if isEditing {
            TextField("Code...", text: Binding(
                get: { content },
                set: { onChange?($0) }
            ))
            .textFieldStyle(.plain)
            .font(.system(.body, design: .monospaced))
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        } else {
            Text(content)
                .font(.system(.body, design: .monospaced))
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

struct ImageBlockView: View {
    let block: NoteBlock

    var body: some View {
        if !block.content.isEmpty {
            VStack(spacing: 4) {
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                Text(block.content)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } else {
            Label("Image placeholder", systemImage: "photo.badge.plus")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

struct TableBlockView: View {
    let content: String
    var isEditing: Bool
    var onChange: ((String) -> Void)?

    var body: some View {
        if isEditing {
            TextField("Table data...", text: Binding(
                get: { content },
                set: { onChange?($0) }
            ))
            .textFieldStyle(.plain)
            .font(.body)
        } else if !content.isEmpty {
            Text(content)
                .font(.body)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(.separator, lineWidth: 1)
                )
        }
    }
}

struct DividerBlockView: View {
    var body: some View {
        Divider()
            .padding(.vertical, 8)
    }
}
