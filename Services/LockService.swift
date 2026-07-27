import Foundation
import LocalAuthentication

@MainActor
final class LockService {
    static let shared = LockService()
    private init() {}

    private let defaults = UserDefaults.standard
    private let lockEnabledKey = "lockEnabled"

    private(set) var isUnlocked = false

    var isLockAvailable: Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    var biometryType: LABiometryType {
        let context = LAContext()
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }

    var isEnabled: Bool {
        get { defaults.bool(forKey: lockEnabledKey) }
        set {
            defaults.set(newValue, forKey: lockEnabledKey)
            if !newValue { isUnlocked = true }
        }
    }

    func authenticate(reason: String = "Unlock notes") async -> Bool {
        guard isEnabled, !isUnlocked else { return true }
        let context = LAContext()
        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            if success { isUnlocked = true }
            return success
        } catch {
            isUnlocked = false
            return false
        }
    }

    func lock() {
        isUnlocked = false
    }
}
