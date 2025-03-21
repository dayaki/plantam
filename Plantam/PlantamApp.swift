import SwiftUI

@main
struct PlantamApp: App {
    @State private var isOnboardingCompleted = UserDefaultsManager.isOnboardingCompleted
    
    var body: some Scene {
        WindowGroup {
            if isOnboardingCompleted {
                ContentView()
            } else {
                OnboardingView(isOnboardingCompleted: $isOnboardingCompleted)
            }
        }
    }
}
