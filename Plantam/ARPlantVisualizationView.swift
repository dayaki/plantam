import SwiftUI
import ARKit
import RealityKit
import Combine

// MARK: - AR Content View
struct ARPlantVisualizationView: View {
    let image: UIImage
    let lightLevel: LightLevel
    let plantName: String?
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var arViewModel = ARViewModel()
    @State private var showPlacementButtons = false
    @State private var selectedPlantType: PlantType? = nil
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // AR View Container
            ARViewContainer(arViewModel: arViewModel)
                .edgesIgnoringSafeArea(.all)
            
            // UI Overlay
            VStack {
                // Top Bar
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("AR Plant Placement")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Button(action: {
                        arViewModel.resetScene()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                Spacer()
                
                // Instructions
                if !arViewModel.isPlaneDetected {
                    Text("Move your device around to detect surfaces")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                        .padding(.bottom, 20)
                } else if !showPlacementButtons {
                    Button(action: {
                        showPlacementButtons = true
                    }) {
                        Text("Tap to Place Plants")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                            .padding(.bottom, 20)
                    }
                }
                
                // Plant Selection
                if showPlacementButtons {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(PlantType.allCases.filter { $0.suitableFor.contains(lightLevel) }, id: \.self) { plantType in
                                Button(action: {
                                    selectedPlantType = plantType
                                    arViewModel.plantToPlace = plantType
                                }) {
                                    VStack {
                                        ZStack {
                                            Circle()
                                                .fill(Color(plantType.color).opacity(0.3))
                                                .frame(width: 70, height: 70)
                                            
                                            Image(systemName: plantType.icon)
                                                .font(.system(size: 30))
                                                .foregroundColor(Color(plantType.color))
                                        }
                                        .overlay(
                                            Circle()
                                                .stroke(selectedPlantType == plantType ? Color.white : Color.clear, lineWidth: 3)
                                        )
                                        
                                        Text(plantType.name)
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .frame(width: 80)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(15)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            // Set the light level in the AR view model
            arViewModel.currentLightLevel = lightLevel
        }
    }
}

// MARK: - AR View Container
struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var arViewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        
        // Run the session
        arView.session.run(config)
        
        // Set up coaching overlay
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arView.addSubview(coachingOverlay)
        
        // Set up tap gesture
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapGesture)
        
        // Set up the coordinator
        context.coordinator.arView = arView
        context.coordinator.viewModel = arViewModel
        
        // Set up plane detection callback
        arView.scene.anchors.addAnchorUpdateObserver { anchor in
            guard anchor is ARPlaneAnchor else { return }
            DispatchQueue.main.async {
                arViewModel.isPlaneDetected = true
            }
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Update the AR view if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        var arView: ARView?
        var viewModel: ARViewModel?
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView, let viewModel = viewModel, let plantType = viewModel.plantToPlace else { return }
            
            // Get tap location
            let tapLocation = gesture.location(in: arView)
            
            // Perform ray-cast to find where to place the object
            let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
            
            if let firstResult = results.first {
                // Create anchor at the tap location
                let anchor = AnchorEntity(world: firstResult.worldTransform)
                
                // Create a plant entity based on the selected type
                let plantEntity = createPlantEntity(for: plantType, lightLevel: viewModel.currentLightLevel)
                
                // Add the plant to the anchor
                anchor.addChild(plantEntity)
                
                // Add the anchor to the scene
                arView.scene.addAnchor(anchor)
            }
        }
        
        private func createPlantEntity(for plantType: PlantType, lightLevel: LightLevel) -> ModelEntity {
            // Create a simple 3D representation of the plant
            // In a real app, you would load actual 3D models
            
            // Create a material with the plant's color
            var material = SimpleMaterial()
            material.baseColor = MaterialColorParameter.color(UIColor(plantType.color))
            material.roughness = MaterialScalarParameter(0.5)
            material.metallic = MaterialScalarParameter(0.0)
            
            // Create a mesh for the plant based on type
            let mesh: MeshResource
            let scale: SIMD3<Float>
            
            switch plantType {
            case .smallPlant:
                mesh = .generateSphere(radius: 0.05)
                scale = [0.8, 1.0, 0.8]
            case .mediumPlant:
                mesh = .generateSphere(radius: 0.1)
                scale = [1.0, 1.2, 1.0]
            case .tallPlant:
                mesh = .generateCone(height: 0.3, radius: 0.1)
                scale = [1.0, 1.5, 1.0]
            case .hangingPlant:
                mesh = .generateSphere(radius: 0.1)
                scale = [1.2, 0.8, 1.2]
            case .cactus:
                mesh = .generateCylinder(height: 0.2, radius: 0.05)
                scale = [0.8, 1.0, 0.8]
            }
            
            // Create the entity
            let entity = ModelEntity(mesh: mesh, materials: [material])
            
            // Add a "stem" for plants that need it
            if plantType != .cactus && plantType != .smallPlant {
                var stemMaterial = SimpleMaterial()
                stemMaterial.baseColor = MaterialColorParameter.color(.brown)
                
                let stemMesh = MeshResource.generateCylinder(height: 0.1, radius: 0.01)
                let stemEntity = ModelEntity(mesh: stemMesh, materials: [stemMaterial])
                
                // Position the stem below the main part
                stemEntity.position = [0, -0.1, 0]
                entity.addChild(stemEntity)
            }
            
            // Scale the entity based on plant type
            entity.scale = scale
            
            // Adjust the entity's appearance based on light level
            adjustEntityForLightLevel(entity: entity, lightLevel: lightLevel)
            
            return entity
        }
        
        private func adjustEntityForLightLevel(entity: ModelEntity, lightLevel: LightLevel) {
            // Adjust the entity's appearance based on light level
            // This is a simple implementation - in a real app, you might adjust textures or models
            
            switch lightLevel {
            case .low:
                // Make plants in low light slightly darker
                if var material = entity.model?.materials.first as? SimpleMaterial {
                    material.baseColor = MaterialColorParameter.color(
                        UIColor(entity.model?.materials.first?.baseColor.tint.rgba ?? [0, 0, 0, 0]).withAlphaComponent(0.8)
                    )
                    entity.model?.materials = [material]
                }
            case .high:
                // Make plants in high light slightly brighter
                if var material = entity.model?.materials.first as? SimpleMaterial {
                    material.baseColor = MaterialColorParameter.color(
                        UIColor(entity.model?.materials.first?.baseColor.tint.rgba ?? [0, 0, 0, 0]).withAlphaComponent(1.0)
                    )
                    entity.model?.materials = [material]
                }
            default:
                // Medium light is the default
                break
            }
        }
    }
}

// MARK: - AR View Model
class ARViewModel: ObservableObject {
    @Published var isPlaneDetected = false
    @Published var plantToPlace: PlantType? = nil
    @Published var currentLightLevel: LightLevel = .medium
    
    func resetScene() {
        // Reset the AR scene - in a real implementation, this would clear all anchors
        plantToPlace = nil
        // The ARView would need to be reset here as well
    }
}

// MARK: - Plant Types
enum PlantType: String, CaseIterable {
    case smallPlant = "Small Plant"
    case mediumPlant = "Medium Plant"
    case tallPlant = "Tall Plant"
    case hangingPlant = "Hanging Plant"
    case cactus = "Cactus"
    
    var name: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .smallPlant: return "leaf.fill"
        case .mediumPlant: return "leaf.circle.fill"
        case .tallPlant: return "leaf.arrow.triangle.circlepath"
        case .hangingPlant: return "cloud.drizzle.fill"
        case .cactus: return "tortoise.fill"
        }
    }
    
    var color: UIColor {
        switch self {
        case .smallPlant: return .systemGreen
        case .mediumPlant: return .systemTeal
        case .tallPlant: return .systemIndigo
        case .hangingPlant: return .systemPurple
        case .cactus: return .systemYellow
        }
    }
    
    var suitableFor: [LightLevel] {
        switch self {
        case .smallPlant: return [.low, .medium, .high]
        case .mediumPlant: return [.medium, .high]
        case .tallPlant: return [.medium, .high]
        case .hangingPlant: return [.low, .medium]
        case .cactus: return [.high]
        }
    }
}