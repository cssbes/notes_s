import SwiftUI

struct FolderListView: View {
    @State private var viewModel: FolderViewModel
    @State private var showCreateSheet = false

    init(viewModel: FolderViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.folders.isEmpty {
                EmptyStateView(
                    title: "No Folders",
                    message: "Create folders to organize your notes.",
                    systemImage: "folder",
                    actionTitle: "New Folder",
                    action: { showCreateSheet = true }
                )
            } else {
                List {
                    ForEach(viewModel.folders) { folder in
                        FolderRowView(folder: folder)
                            .contextMenu {
                                Button {
                                    viewModel.selectedParentFolder = folder
                                    showCreateSheet = true
                                } label: {
                                    Label("Add Subfolder", systemImage: "folder.badge.plus")
                                }

                                Divider()

                                Button(role: .destructive) {
                                    viewModel.deleteFolder(folder)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteFolder(viewModel.folders[index])
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Folders")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet($showCreateSheet) {
            createFolderSheet
        }
        .onAppear { viewModel.loadFolders() }
    }

    private var createFolderSheet: some View {
        NavigationStack {
            Form {
                TextField("Folder Name", text: $viewModel.newFolderName)

                if let parent = viewModel.selectedParentFolder {
                    HStack {
                        Text("Parent:")
                        Text(parent.name)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("New Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.newFolderName = ""
                        viewModel.selectedParentFolder = nil
                        showCreateSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        viewModel.createFolder()
                        showCreateSheet = false
                    }
                    .disabled(viewModel.newFolderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.height(200)])
    }
}
