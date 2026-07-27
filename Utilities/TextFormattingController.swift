import UIKit

@MainActor
@Observable
final class TextFormattingController {
    weak var textView: UITextView?

    func toggleBold() {
        toggleTrait(.traitBold)
    }

    func toggleItalic() {
        toggleTrait(.traitItalic)
    }

    func toggleUnderline() {
        guard let textView, let range = selectedRange() else { return }
        let attrs = textView.attributedText.attributes(at: range.location, effectiveRange: nil)
        if attrs[.underlineStyle] != nil {
            textView.textStorage.removeAttribute(.underlineStyle, range: range)
        } else {
            textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        }
        notifyChange()
    }

    func applyHeading(_ level: Int) {
        guard let textView, let range = selectedRange() else { return }
        let sizes: [CGFloat] = [28, 22, 18]
        let size = sizes[min(level - 1, 2)]
        let font = UIFont.boldSystemFont(ofSize: size)
        textView.textStorage.addAttribute(.font, value: font, range: range)
        notifyChange()
    }

    func toggleBulletList() {
        guard let textView, let r = textView.selectedTextRange else { return }
        if let text = textView.text(in: r) {
            let lines = text.components(separatedBy: .newlines)
            let bulleted = lines.map { "\u{2022} \($0)" }.joined(separator: "\n")
            textView.replace(r, withText: bulleted)
        }
        notifyChange()
    }

    func toggleNumberedList() {
        guard let textView, let r = textView.selectedTextRange else { return }
        if let text = textView.text(in: r) {
            let lines = text.components(separatedBy: .newlines)
            let numbered = lines.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
            textView.replace(r, withText: numbered)
        }
        notifyChange()
    }

    func applyQuote() {
        guard let textView, let r = textView.selectedTextRange else { return }
        if let text = textView.text(in: r) {
            let lines = text.components(separatedBy: .newlines)
            let quoted = lines.map { "> \($0)" }.joined(separator: "\n")
            textView.replace(r, withText: quoted)
        }
        notifyChange()
    }

    func applyCode() {
        guard let textView, let range = selectedRange() else { return }
        let font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.textStorage.addAttribute(.font, value: font, range: range)
        let bgColor = UIColor.systemGray6
        textView.textStorage.addAttribute(.backgroundColor, value: bgColor, range: range)
        notifyChange()
    }

    private func toggleTrait(_ trait: UIFontDescriptor.SymbolicTraits) {
        guard let textView, let range = selectedRange(), range.length > 0 else { return }
        let attrs = textView.attributedText.attributes(at: range.location, effectiveRange: nil)
        let currentFont = attrs[.font] as? UIFont ?? .systemFont(ofSize: 16)
        var traits = currentFont.fontDescriptor.symbolicTraits
        if traits.contains(trait) { traits.remove(trait) } else { traits.insert(trait) }
        if let descriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) {
            let newFont = UIFont(descriptor: descriptor, size: currentFont.pointSize)
            textView.textStorage.addAttribute(.font, value: newFont, range: range)
        }
        notifyChange()
    }

    private func selectedRange() -> NSRange? {
        guard let textView else { return nil }
        let range = textView.selectedRange
        if range.length == 0 {
            let lineRange = (textView.text as NSString).paragraphRange(for: range)
            return lineRange
        }
        return range
    }

    private func notifyChange() {
        guard let textView else { return }
        textView.delegate?.textViewDidChange?(textView)
    }
}
