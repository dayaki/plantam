import SwiftUI
import UIKit
import Foundation

struct PlantRecommendationView: View {
    let image: UIImage
    let lightLevel: LightLevel
    
    @State private var recommendations: PlantRecommendations?
    @State private var isLoading = true
    @State private var error: Error?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Image with light level indicator
                    ZStack(alignment: .bottomLeading) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                        
                        HStack {
                            Image(systemName: lightLevel.icon)
                                .foregroundColor(.white)
                            
                            Text(lightLevel.rawValue)
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        }
                        .padding(8)
                        .background(Color(lightLevel.color).opacity(0.8))
                        .cornerRadius(8)
                        .padding(12)
                    }
                    
                    if isLoading {
                        VStack(spacing: 20) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                                .padding(.bottom, 10)
                            
                            Text("Getting plant recommendations...")
                                .font(.headline)
                            
                            Text("We're analyzing your room and finding the perfect plants for your lighting conditions.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else if let error = error {
                        VStack(spacing: 15) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                                .padding(.bottom, 10)
                            
                            Text("Couldn't Load Recommendations")
                                .font(.headline)
                            
                            Text("We're having trouble connecting to our plant database. Here are some general recommendations for \(lightLevel.rawValue) conditions.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            // Show fallback recommendations
                            if let fallbackRecommendations = OpenAIService().fallbackRecommendations(for: lightLevel) {
                                recommendationsList(fallbackRecommendations)
                            }
                        }
                        .padding()
                    } else if let recommendations = recommendations {
                        // Title
                        Text("Recommended Plants")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Description
                        Text("These plants are perfect for the \(lightLevel.rawValue.lowercased()) conditions in your space.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        // Recommendations list
                        recommendationsList(recommendations)
                    }
                }
                .padding()
            }
            .navigationTitle("Plant Recommendations")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadRecommendations()
            }
        }
    }
    
    private func loadRecommendations() {
        let service = OpenAIService()
        
        service.getPlantRecommendations(image: image, lightLevel: lightLevel) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let recommendations):
                    self.recommendations = recommendations
                case .failure(let error):
                    self.error = error
                    print("Error getting recommendations: \(error)")
                }
            }
        }
    }
    
    private func recommendationsList(_ recommendations: PlantRecommendations) -> some View {
        VStack(spacing: 16) {
            ForEach(recommendations.recommendations) { plant in
                plantCard(plant)
            }
        }
    }
    
    private func plantCard(_ plant: PlantRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Plant name and icon
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(plant.commonName)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(plant.scientificName)
                        .font(.caption)
                        .italic()
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Care instructions
            VStack(alignment: .leading, spacing: 8) {
                Label("Care Instructions", systemImage: "drop.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Text(plant.careInstructions)
                    .font(.body)
                    .padding(.leading, 4)
            }
            
            // Suitability reason
            VStack(alignment: .leading, spacing: 8) {
                Label("Why It's Perfect", systemImage: "checkmark.circle.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Text(plant.suitabilityReason)
                    .font(.body)
                    .padding(.leading, 4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Preview provider
struct PlantRecommendationView_Previews: PreviewProvider {
    static var previews: some View {
        // Create sample data for preview
        let sampleImage = UIImage(systemName: "photo")!
        
        PlantRecommendationView(
            image: sampleImage,
            lightLevel: .medium
        )
    }
}