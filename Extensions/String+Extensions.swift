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

    var strippingHTML: String {
        replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
    }
}

