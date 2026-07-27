import SwiftUI

struct NoteEditorView: View {
    @State private var viewModel: NoteEditorViewModel
    @State private var formattingController = TextFormattingController()
    @Environment(\.dismiss) private var dismiss
    @Environment(AppCoordinator.self) private var coordinator
    @FocusState private var isTitleFocused: Bool
    @FocusState private var isEditorFocused: Bool
    @State private var showToolbar = false

    init(viewModel: NoteEditorViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            if showToolbar {
                FormattingToolbar(
                    onBold: { formattingController.toggleBold() },
                    onItalic: { formattingController.toggleItalic() },
                    onUnderline: { formattingController.toggleUnderline() },
                    onStrikethrough: { formattingController.toggleStrikethrough() },
                    onHighlight: { formattingController.toggleHighlight() },
                    onHeading: { formattingController.applyHeading($0) },
                    onBulletList: { formattingController.toggleBulletList() },
                    onNumberedList: { formattingController.toggleNumberedList() },
                    onChecklist: { formattingController.toggleChecklist() },
                    onQuote: { formattingController.applyQuote() },
                    onCode: { formattingController.applyCode() },
                    onLink: { formattingController.addLink() },
                    onDivider: { formattingController.insertDivider() },
                    onImage: { formattingController.insertImagePlaceholder() },
                    onUndo: { viewModel.undo() },
                    onRedo: { viewModel.redo() },
                    canUndo: viewModel.canUndo,
                    canRedo: viewModel.canRedo
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            ScrollView {
                VStack(spacing: 16) {
                    titleField
                    statisticsBar
                    editorArea
                }
                .padding(20)
            }
        }
        .background(Color.themeBackground)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Done") { viewModel.save(); dismiss() }
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.themeAccent)
            }
            ToolbarItem(placement: .principal) {
                Text(viewModel.note.displayTitle).font(.system(size: 14, design: .rounded)).foregroundStyle(Color.themeSubtle)
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Button { withAnimation(.easeInOut(duration: 0.2)) { showToolbar.toggle() } } label: {
                        Image(systemName: showToolbar ? "keyboard.chevron.compact.down" : "pencil.tip")
                            .font(.system(size: 14)).foregroundStyle(Color.themeText)
                    }
                    Menu {
                        Button { viewModel.toggleFavorite() } label: {
                            Label(viewModel.note.isFavorite ? "Unfavorite" : "Favorite", systemImage: viewModel.note.isFavorite ? "star.slash" : "star")
                        }
                        Button { viewModel.togglePin() } label: {
                            Label(viewModel.note.isPinned ? "Unpin" : "Pin", systemImage: viewModel.note.isPinned ? "pin.slash" : "pin")
                        }
                        Section {
                            Button { viewModel.showEmojiPicker = true } label: { Label("Set Emoji", systemImage: "face.smiling") }
                            Button { viewModel.showColorPicker = true } label: { Label("Set Color", systemImage: "paintpalette") }
                        }
                        Section {
                            Button { viewModel.duplicateNote() } label: { Label("Duplicate", systemImage: "doc.on.doc") }
                            Button { viewModel.showFolderPicker = true } label: { Label("Move to Folder", systemImage: "folder") }
                        }
                        Section {
                            Menu("Export") {
                                Button("Markdown") { shareExport(viewModel.exportMarkdown(), name: "note.md") }
                                Button("Plain Text") { shareExport(viewModel.exportPlainText(), name: "note.txt") }
                                Button("JSON") { shareExport(viewModel.exportJSON(), name: "note.json") }
                            }
                        }
                        Section {
                            Button(role: .destructive) { viewModel.showDeleteConfirmation = true } label: { Label("Delete", systemImage: "trash") }
                        }
                    } label: { Image(systemName: "ellipsis").font(.system(size: 14)).foregroundStyle(Color.themeText) }
                }
            }
        }
        .alert("Delete Note?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { viewModel.deleteNote(); dismiss() }
        } message: { Text("This note will be moved to trash.") }
        .sheet(isPresented: $viewModel.showFolderPicker) { folderPickerSheet }
        .sheet(isPresented: $viewModel.showEmojiPicker) { emojiPickerSheet }
        .sheet(isPresented: $viewModel.showColorPicker) { colorPickerSheet }
        .onChange(of: viewModel.content) { _, _ in viewModel.autoSave() }
        .onDisappear { viewModel.save() }
    }

    private var titleField: some View {
        HStack(spacing: 10) {
            if !viewModel.note.emoji.isEmpty {
                Text(viewModel.note.emoji).font(.system(size: 28))
            }
            VStack(alignment: .leading, spacing: 2) {
                TextField("Title", text: $viewModel.title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.themeText)
                    .textFieldStyle(.plain)
                    .focused($isTitleFocused)
                if !viewModel.isNew {
                    Text(viewModel.note.createdAt, style: .date)
                        .font(.caption).foregroundStyle(Color.themeSubtle)
                }
            }
        }
    }

    private var statisticsBar: some View {
        HStack(spacing: 8) {
            if viewModel.isSaving {
                Image(systemName: "icloud.and.arrow.up").font(.caption2).foregroundStyle(Color.themeSubtle)
            }
            Text("\(viewModel.wordCount) words  ·  \(viewModel.readingTime) min").font(.caption).foregroundStyle(Color.themeSubtle)
            Spacer()
        }
    }

    private var editorArea: some View {
        RichTextEditor(htmlContent: $viewModel.content, formattingController: formattingController)
            .focused($isEditorFocused)
            .frame(minHeight: 300)
            .background(Color.themeSurface)
            .cornerRadius(12)
    }

    private func shareExport(_ data: Data?, name: String) {
        guard let data else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        try? data.write(to: url)
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let root = window.rootViewController {
            root.present(av, animated: true)
        }
    }

    private var folderPickerSheet: some View {
        NavigationStack {
            FolderPickerView(noteService: coordinator.container.noteService, selectedFolder: viewModel.note.folder) { folder in
                viewModel.moveToFolder(folder); viewModel.showFolderPicker = false
            }
        }
    }

    private var emojiPickerSheet: some View {
        NavigationStack { EmojiPickerView(selectedEmoji: viewModel.note.emoji) { emoji in viewModel.note.emoji = emoji; viewModel.showEmojiPicker = false } }
    }

    private var colorPickerSheet: some View {
        NavigationStack { NoteColorPickerView(selectedHex: viewModel.note.colorHex) { hex in viewModel.note.colorHex = hex; viewModel.showColorPicker = false } }
    }
}

struct FolderPickerView: View {
    @State private var viewModel: FolderViewModel
    let selectedFolder: Folder?
    let onSelect: (Folder?) -> Void

    init(noteService: NoteService, selectedFolder: Folder?, onSelect: @escaping (Folder?) -> Void) {
        self.selectedFolder = selectedFolder; self.onSelect = onSelect
        self._viewModel = State(initialValue: FolderViewModel(noteService: noteService))
    }

    var body: some View {
        List {
            Button { onSelect(nil) } label: {
                HStack { Image(systemName: "tray").foregroundStyle(Color.themeAccent); Text("No Folder"); Spacer(); if selectedFolder == nil { Image(systemName: "checkmark").foregroundStyle(Color.themeAccent) } }
            }
            ForEach(viewModel.folders) { folder in
                Button { onSelect(folder) } label: {
                    HStack { Image(systemName: folder.icon).foregroundStyle(Color.themeAccent); Text(folder.name); Spacer(); if selectedFolder?.id == folder.id { Image(systemName: "checkmark").foregroundStyle(Color.themeAccent) } }
                }
            }
        }
        .navigationTitle("Move to Folder").navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.loadFolders() }
    }
}

struct EmojiPickerView: View {
    let selectedEmoji: String
    let onSelect: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    let emojis = ["📝", "📌", "⭐", "❤️", "✅", "🎯", "💡", "🚀", "🎨", "📚", "🔖", "💭", "🗂️", "📎", "🔗", "📅", "⏰", "🏷️", "📊", "🎵", "📸", "✏️", "📖", "💼", "🎉", "🔔", "⚡", "🔥", "💎", "🌟"]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                ForEach(emojis, id: \.self) { emoji in
                    Button { onSelect(emoji); dismiss() } label: {
                        Text(emoji).font(.system(size: 36)).opacity(emoji == selectedEmoji ? 1 : 0.7)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(emoji == selectedEmoji ? Color.themeAccent : Color.clear, lineWidth: 2))
                    }.buttonStyle(.plain)
                }
            }.padding()
        }
        .navigationTitle("Choose Emoji").navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Cancel") { dismiss() } } }
    }
}

struct NoteColorPickerView: View {
    let selectedHex: String
    let onSelect: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    let colors: [(name: String, hex: String)] = [
        ("Amber", "#C77D4A"), ("Terra", "#8B6B5C"), ("Slate", "#5C6B7A"),
        ("Sage", "#6B8B6B"), ("Clay", "#C77D4A"), ("Rust", "#B86C5A"),
        ("Ochre", "#C99A4A"), ("Moss", "#6B8B5C"), ("Cocoa", "#7A6B5C"),
        ("Mist", "#9EA8B8"), ("Sand", "#C4B8A8"), ("Dusk", "#8B7A9E")
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
                ForEach(colors, id: \.hex) { color in
                    Button { onSelect(color.hex); dismiss() } label: {
                        VStack(spacing: 6) {
                            Circle().fill(Color(hex: color.hex) ?? .orange).frame(width: 44, height: 44)
                                .overlay(Circle().stroke(color.hex == selectedHex ? Color.primary : Color.clear, lineWidth: 3))
                            Text(color.name).font(.caption2).foregroundStyle(Color.themeSubtle)
                        }
                    }.buttonStyle(.plain)
                }
            }.padding()
        }
        .navigationTitle("Choose Color").navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Cancel") { dismiss() } } }
    }
}
