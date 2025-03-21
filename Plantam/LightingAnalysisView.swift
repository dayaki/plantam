import SwiftUI

struct LightingAnalysisView: View {
    let image: UIImage
    let zones: [LightingZone]
    let summary: [LightLevel: Double]
    let overallLightLevel: LightLevel
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingVisualization = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Image with visualization toggle
                    ZStack(alignment: .topTrailing) {
                        if showingVisualization, let visualizationImage = LightingAnalyzer().generateZoneVisualization(image: image, zones: zones) {
                            Image(uiImage: visualizationImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(12)
                        } else {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            showingVisualization.toggle()
                        }) {
                            HStack {
                                Image(systemName: showingVisualization ? "eye.slash" : "eye")
                                Text(showingVisualization ? "Hide Zones" : "Show Zones")
                            }
                            .font(.caption)
                            .padding(8)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(12)
                        }
                    }
                    
                    // Overall light level
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Overall Light Level")
                            .font(.headline)
                        
                        HStack(spacing: 15) {
                            Image(systemName: overallLightLevel.icon)
                                .font(.system(size: 36))
                                .foregroundColor(Color(overallLightLevel.color))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(overallLightLevel.rawValue)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(overallLightLevel.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(overallLightLevel.color).opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Light distribution
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Light Distribution")
                            .font(.headline)
                        
                        ForEach(LightLevel.allCases, id: \.self) { level in
                            let percentage = summary[level] ?? 0
                            if percentage > 0 {
                                HStack {
                                    Image(systemName: level.icon)
                                        .foregroundColor(Color(level.color))
                                    
                                    Text(level.rawValue)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(percentage))%")
                                        .fontWeight(.semibold)
                                }
                                
                                ProgressView(value: percentage, total: 100)
                                    .progressViewStyle(LinearProgressViewStyle(tint: Color(level.color)))
                                    .padding(.bottom, 8)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Plant recommendations
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Plant Recommendations")
                            .font(.headline)
                        
                        // Recommendations based on the dominant light level
                        let dominantLevel = summary.max(by: { $0.value < $1.value })?.key ?? overallLightLevel
                        
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(.green)
                                Text("Best Plants for Your Space")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            
                            Text(dominantLevel.description)
                                .font(.body)
                            
                            Text("In the next step, we'll provide personalized plant recommendations using AI.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Placement tips
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Placement Tips")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            tipRow(icon: "arrow.up.left.and.arrow.down.right", title: "Consider Light Zones", description: "Place plants according to the light zones identified in your room.")
                            
                            Divider()
                            
                            tipRow(icon: "clock", title: "Monitor Seasonal Changes", description: "Light conditions may change with seasons. Reassess periodically.")
                            
                            Divider()
                            
                            tipRow(icon: "move.3d", title: "Rotate Plants", description: "Rotate plants occasionally to ensure even growth.")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Lighting Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func tipRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// Preview provider
struct LightingAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        // Create sample data for preview
        let sampleImage = UIImage(systemName: "photo")!
        let sampleZones = [
            LightingZone(level: .low, percentage: 30, region: CGRect(x: 0, y: 0, width: 0.33, height: 0.33)),
            LightingZone(level: .medium, percentage: 40, region: CGRect(x: 0.33, y: 0.33, width: 0.33, height: 0.33)),
            LightingZone(level: .high, percentage: 30, region: CGRect(x: 0.66, y: 0.66, width: 0.33, height: 0.33))
        ]
        let sampleSummary: [LightLevel: Double] = [
            .low: 30,
            .medium: 40,
            .high: 30
        ]
        
        return LightingAnalysisView(
            image: sampleImage,
            zones: sampleZones,
            summary: sampleSummary,
            overallLightLevel: .medium
        )
    }
}
