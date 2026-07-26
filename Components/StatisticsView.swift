import SwiftUI

struct StatisticsView: View {
    let wordCount: Int
    let characterCount: Int
    let readingTime: Int

    var body: some View {
        HStack(spacing: 16) {
            StatItem(value: "\(wordCount)", label: "words")
            StatItem(value: "\(characterCount)", label: "chars")
            StatItem(value: "\(readingTime)", label: "min read")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(10)
    }
}

private struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Text(value)
                .fontWeight(.medium)
            Text(label)
                .foregroundStyle(.tertiary)
        }
    }
}
