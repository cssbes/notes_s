import SwiftUI
import UIKit

struct RichTextEditor: UIViewRepresentable {
    @Binding var htmlContent: String
    var formattingController: TextFormattingController
    var isEditable: Bool = true

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.isEditable = isEditable
        tv.delegate = context.coordinator
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.backgroundColor = .clear
        tv.attributedText = Self.parseHTML(htmlContent) ?? NSAttributedString(string: htmlContent)
        formattingController.textView = tv
        return tv
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if !context.coordinator.isEditing && context.coordinator.lastHTML != htmlContent {
            uiView.attributedText = Self.parseHTML(htmlContent) ?? NSAttributedString(string: htmlContent)
            context.coordinator.lastHTML = htmlContent
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextEditor
        var isEditing = false
        var lastHTML = ""

        init(_ parent: RichTextEditor) {
            self.parent = parent
            self.lastHTML = parent.htmlContent
        }

        func textViewDidChange(_ textView: UITextView) {
            isEditing = true
            let html = RichTextEditor.toHTML(textView.attributedText)
            parent.htmlContent = html
            lastHTML = html
            isEditing = false
        }
    }

    private static func parseHTML(_ html: String) -> NSAttributedString? {
        guard !html.isEmpty else { return nil }
        if html.contains("<") {
            guard let data = html.data(using: .utf8) else { return nil }
            let opts: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            return try? NSAttributedString(data: data, options: opts, documentAttributes: nil)
        }
        return nil
    }

    private static func toHTML(_ attributed: NSAttributedString) -> String {
        guard let data = try? attributed.data(
            from: NSRange(location: 0, length: attributed.length),
            documentAttributes: [.documentType: NSAttributedString.DocumentType.html]
        ) else { return attributed.string }
        return String(data: data, encoding: .utf8) ?? attributed.string
    }
}
