import SwiftUI

struct NoteEditorView: View {
    @State private var viewModel: NoteEditorViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTitleFocused: Bool

    init(viewModel: NoteEditorViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                titleField
                statisticsBar
                FormattingToolbar(
                    onBold: {},
                    onItalic: {},
                    onUnderline: {},
                    onHeading: { _ in },
                    onBulletList: {},
                    onNumberedList: {},
                    onChecklist: {},
                    onQuote: {},
                    onCode: {},
                    onUndo: { viewModel.undo() },
                    onRedo: { viewModel.redo() },
                    canUndo: viewModel.canUndo,
                    canRedo: viewModel.canRedo
                )
                contentEditor
                blockList
                addBlockButton
            }
            .padding()
        }
        .navigationTitle(viewModel.isNew ? "New Note" : "Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Done") {
                    viewModel.save()
                    dismiss()
                }
                .fontWeight(.semibold)
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 8) {
                    Button {
                        viewModel.toggleFavorite()
                    } label: {
                        Image(systemName: viewModel.note.isFavorite ? "star.fill" : "star")
                            .foregroundStyle(viewModel.note.isFavorite ? .yellow : .primary)
                    }

                    Button {
                        viewModel.togglePin()
                    } label: {
                        Image(systemName: viewModel.note.isPinned ? "pin.fill" : "pin")
                    }

                    Menu {
                        Button(role: .destructive) {
                            viewModel.showDeleteConfirmation = true
                        } label: {
                            Label("Delete Note", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .alert("Delete Note?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteNote()
                dismiss()
            }
        } message: {
            Text("This note will be moved to trash.")
        }
        .onChange(of: viewModel.content) { _, _ in
            viewModel.autoSave()
        }
        .onDisappear {
            viewModel.save()
        }
    }

    private var titleField: some View {
        TextField("Title", text: $viewModel.title)
            .font(.largeTitle)
            .fontWeight(.bold)
            .textFieldStyle(.plain)
            .focused($isTitleFocused)
    }

    private var statisticsBar: some View {
        StatisticsView(
            wordCount: viewModel.wordCount,
            characterCount: viewModel.characterCount,
            readingTime: viewModel.readingTime
        )
    }

    private var contentEditor: some View {
        TextEditor(text: $viewModel.content)
            .font(.body)
            .frame(minHeight: 200)
            .scrollContentBackground(.hidden)
            .background(.clear)
    }

    private var blockList: some View {
        ForEach(Array(viewModel.blocks.enumerated()), id: \.element.id) { index, block in
            HStack(spacing: 8) {
                BlockTypeMenu(type: block.type) { newType in
                    withAnimation {
                        viewModel.blocks[index].type = newType
                    }
                }

                BlockView(
                    block: block,
                    isEditing: true,
                    onContentChange: { newContent in
                        viewModel.updateBlock(block, content: newContent)
                    }
                )

                Button {
                    withAnimation {
                        viewModel.removeBlock(at: index)
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var addBlockButton: some View {
        Button {
            viewModel.addBlock()
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.tertiary)
                Text("Add block")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }
}

struct BlockTypeMenu: View {
    let type: BlockType
    let onChange: (BlockType) -> Void

    var body: some View {
        Menu {
            ForEach(BlockType.allCases) { blockType in
                Button {
                    onChange(blockType)
                } label: {
                    Label(blockType.displayName, systemImage: blockType.systemImage)
                }
            }
        } label: {
            Image(systemName: type.systemImage)
                .font(.caption)
                .foregroundStyle(.tertiary)
                .frame(width: 24)
        }
        .buttonStyle(.plain)
    }
}
