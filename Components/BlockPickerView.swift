import SwiftUI

struct BlockPickerView: View {
    var onSelect: (BlockType) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(BlockType.allCases) { type in
                    Button {
                        onSelect(type)
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: type.systemImage)
                                .font(.title3)
                                .foregroundStyle(.tint)
                                .frame(width: 44, height: 44)
                                .background(.tint.opacity(0.1))
                                .cornerRadius(10)

                            Text(type.displayName)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .frame(height: 200)
    }
}
