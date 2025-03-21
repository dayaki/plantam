import Foundation

class UserDefaultsManager {
    // MARK: - Keys
    private enum Keys {
        static let isOnboardingCompleted = "isOnboardingCompleted"
    }
    
    // MARK: - Onboarding
    
    /// Check if the user has completed the onboarding process
    static var isOnboardingCompleted: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isOnboardingCompleted)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.isOnboardingCompleted)
        }
    }
    
    /// Reset onboarding status (for testing)
    static func resetOnboardingStatus() {
        UserDefaults.standard.removeObject(forKey: Keys.isOnboardingCompleted)
    }
}