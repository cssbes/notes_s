import Foundation

extension String {
    func markdownToAttributed() -> AttributedString {
        guard !isEmpty else { return AttributedString() }
        return (try? AttributedString(markdown: self)) ?? AttributedString(self)
    }

    func truncate(length: Int, trailing: String = "...") -> String {
        if count > length {
            return prefix(length) + trailing
        }
        return self
    }

    var isEmptyOrWhitespace: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func removingExtraSpaces() -> String {
        split { $0.isWhitespace || $0.isNewline }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}

