import SwiftUI

struct NoteEditorView: View {
    @State private var viewModel: NoteEditorViewModel
    @State private var formattingController = TextFormattingController()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTitleFocused: Bool

    init(viewModel: NoteEditorViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            titleField
                .padding(.horizontal)
                .padding(.top, 8)

            FormattingToolbar(
                onBold: { formattingController.toggleBold() },
                onItalic: { formattingController.toggleItalic() },
                onUnderline: { formattingController.toggleUnderline() },
                onHeading: { formattingController.applyHeading($0) },
                onBulletList: { formattingController.toggleBulletList() },
                onNumberedList: { formattingController.toggleNumberedList() },
                onChecklist: {},
                onQuote: { formattingController.applyQuote() },
                onCode: { formattingController.applyCode() },
                onUndo: { viewModel.undo() },
                onRedo: { viewModel.redo() },
                canUndo: viewModel.canUndo,
                canRedo: viewModel.canRedo
            )
            .padding(.top, 4)

            RichTextEditor(
                htmlContent: $viewModel.content,
                formattingController: formattingController
            )
            .padding(.horizontal)
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
}
