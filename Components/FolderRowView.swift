import SwiftUI

struct FolderRowView: View {
    let folder: Folder
    let depth: Int

    init(folder: Folder, depth: Int = 0) {
        self.folder = folder
        self.depth = depth
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: folder.icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.tint)
                .frame(width: 28, height: 28)
                .background(.tint.opacity(0.1))
                .cornerRadius(6)

            VStack(alignment: .leading, spacing: 2) {
                Text(folder.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text("\(folder.noteCount) notes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            if !folder.childFolders.isEmpty {
                Image(systemName: "chevron.forward")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.leading, CGFloat(depth * 20))
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
