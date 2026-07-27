import Foundation
import UIKit

struct QuickNoteService {
    static func createQuickNote(title: String, noteService: NoteService) -> Note? {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
        return try? noteService.createNote(title: title)
    }

    static func showQuickNoteAlert(on viewController: UIViewController, noteService: NoteService, onSave: @escaping (Note) -> Void) {
        let alert = UIAlertController(title: "Quick Note", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Note title..."
        }
        alert.addTextField { tf in
            tf.placeholder = "Content (optional)..."
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            let title = alert.textFields?[0].text ?? ""
            let content = alert.textFields?[1].text ?? ""
            if let note = try? noteService.createNote(title: title) {
                if !content.isEmpty {
                    note.content = content
                    try? noteService.updateNote(note)
                }
                onSave(note)
            }
        })
        viewController.present(alert, animated: true)
    }
}
