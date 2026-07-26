import UIKit

final class KeyboardManager: ObservableObject {
    @Published var isKeyboardVisible = false
    @Published var keyboardHeight: CGFloat = 0

    private var notificationCenter: NotificationCenter

    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
        observeKeyboardNotifications()
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    private func observeKeyboardNotifications() {
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        keyboardHeight = frame.height
        isKeyboardVisible = true
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        keyboardHeight = 0
        isKeyboardVisible = false
    }
}
