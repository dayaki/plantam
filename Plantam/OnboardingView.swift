import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingCompleted: Bool
    @State private var currentTab = 0
    
    // Animation properties
    @State private var slideOffset: CGFloat = 0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.2), Color.blue.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                // Skip button
                if currentTab < 5 {
                    HStack {
                        Spacer()
                        Button("Skip") {
                            withAnimation {
                                completeOnboarding()
                            }
                        }
                        .foregroundColor(.gray)
                        .padding()
                    }
                }
                
                // Paging TabView
                TabView(selection: $currentTab) {
                    // Slide 1 - Welcome
                    OnboardingSlideView(
                        title: "Welcome to Plantam 🌱",
                        description: "Discover the best plants for your space and visualize them in your room with AI-powered recommendations and AR placement!",
                        imageName: "leaf.fill",
                        backgroundColor: Color.green.opacity(0.2),
                        useCustomImage: true,
                        customImageName: "WelcomeImage"
                    )
                    .tag(0)
                    
                    // Slide 2 - Light Detection
                    OnboardingSlideView(
                        title: "Smart Light Detection ☀️",
                        description: "Our AI analyzes your room's lighting conditions to suggest the best locations for your plants to thrive.",
                        imageName: "light.max",
                        backgroundColor: Color.yellow.opacity(0.2),
                        useCustomImage: true,
                        customImageName: "LightDetectionImage"
                    )
                    .tag(1)
                    
                    // Slide 3 - AI Recommendations
                    OnboardingSlideView(
                        title: "AI-Powered Plant Recommendations 🤖🌿",
                        description: "Based on your room's lighting, our AI suggests plants that will grow best in your space—no guesswork needed!",
                        imageName: "text.viewfinder",
                        backgroundColor: Color.blue.opacity(0.2),
                        useCustomImage: true,
                        customImageName: "AIRecommendationImage"
                    )
                    .tag(2)
                    
                    // Slide 4 - AR Placement
                    OnboardingSlideView(
                        title: "Place Plants in Your Room with AR 🌍",
                        description: "Use Augmented Reality (AR) to place virtual plants in your space and find the perfect fit before purchasing.",
                        imageName: "camera.viewfinder",
                        backgroundColor: Color.purple.opacity(0.2),
                        useCustomImage: true,
                        customImageName: "ARPlacementImage"
                    )
                    .tag(3)
                    
                    // Slide 5 - Favorites
                    OnboardingSlideView(
                        title: "Save & Organize Your Favorites ❤️",
                        description: "Save your favorite plants, placements, and recommendations to revisit anytime.",
                        imageName: "heart.fill",
                        backgroundColor: Color.red.opacity(0.2),
                        useCustomImage: true,
                        customImageName: "FavoritesImage"
                    )
                    .tag(4)
                    
                    // Slide 6 - Get Started
                    OnboardingSlideView(
                        title: "Ready to Green Up Your Space? 🎉",
                        description: "Let's get started! Capture your room and find the perfect plant placement today!",
                        imageName: "checkmark.circle.fill",
                        backgroundColor: Color.green.opacity(0.2),
                        showButton: true,
                        buttonAction: {
                            withAnimation {
                                completeOnboarding()
                            }
                        }, useCustomImage: true,
                        customImageName: "GetStartedImage"
                    )
                    .tag(5)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .animation(.easeInOut, value: currentTab)
                .transition(.slide)
                
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<6) { index in
                        Circle()
                            .fill(currentTab == index ? Color.green : Color.gray.opacity(0.5))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentTab == index ? 1.2 : 1.0)
                            .animation(.spring(), value: currentTab)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    private func completeOnboarding() {
        // Save that onboarding is completed
        UserDefaultsManager.isOnboardingCompleted = true
        isOnboardingCompleted = true
    }
    
    
    struct OnboardingSlideView: View {
        let title: String
        let description: String
        let imageName: String
        let backgroundColor: Color
        var showButton: Bool = false
        var buttonAction: (() -> Void)? = nil
        var useCustomImage: Bool = false
        var customImageName: String = ""
        
        @State private var isAnimating = false
        
        var body: some View {
            VStack(spacing: 20) {
                Spacer()
                
                // Icon with animation
                if useCustomImage && !customImageName.isEmpty {
                    Image(customImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 140, height: 140)
                        .padding()
                        .background(
                            Circle()
                                .fill(backgroundColor)
                                .frame(width: 200, height: 200)
                        )
                        .scaleEffect(isAnimating ? 1.1 : 0.9)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                        .onAppear {
                            isAnimating = true
                        }
                } else {
                    Image(systemName: imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.green)
                        .padding()
                        .background(
                            Circle()
                                .fill(backgroundColor)
                                .frame(width: 180, height: 180)
                        )
                        .scaleEffect(isAnimating ? 1.1 : 0.9)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                        .onAppear {
                            isAnimating = true
                        }
                }
                
                // Title
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 30)
                
                // Description
                Text(description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                
                Spacer()
                
                // Get Started button (only on last slide)
                if showButton {
                    Button(action: {
                        buttonAction?()
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 50)
                            .padding(.vertical, 16)
                            .background(Color.green)
                            .cornerRadius(30)
                            .shadow(radius: 5)
                    }
                    .padding(.bottom, 50)
                }
            }
            .padding()
        }
    }
    
    struct OnboardingView_Previews: PreviewProvider {
        static var previews: some View {
            OnboardingView(isOnboardingCompleted: .constant(false))
        }
    }
}
