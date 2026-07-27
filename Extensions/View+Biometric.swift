import SwiftUI

extension View {
    func biometricLock() -> some View {
        self.onAppear {
            Task { @MainActor in
                if LockService.shared.isEnabled && !LockService.shared.isUnlocked {
                    _ = await LockService.shared.authenticate()
                }
            }
        }
    }
}
