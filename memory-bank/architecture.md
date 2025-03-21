# Plantam App Architecture

## Project Overview

Plantam is an iOS application that uses device camera, image processing, and AI to analyze room lighting conditions and recommend suitable plants. The app leverages ARKit for visualization and OpenAI for intelligent plant recommendations.

## Project Structure

The project follows a standard iOS application structure with SwiftUI as the primary UI framework:

```
Plantam/
├── Plantam.xcodeproj/      # Xcode project configuration
├── Plantam/                # Main application code
│   ├── PlantamApp.swift    # App entry point and scene configuration
│   ├── ContentView.swift   # Main view controller with integrated camera
│   ├── Info.plist          # App configuration and permissions
│   ├── Assets.xcassets     # Image assets and resources
│   └── Preview Content/    # SwiftUI preview assets
└── Package.swift           # Swift Package Manager configuration
```

## File Descriptions

### PlantamApp.swift
The main entry point for the application. Defines the `App` protocol implementation and sets up the primary scene.

### ContentView.swift
The main view of the application that includes:
- Welcome screen with app branding and instructions
- Button to activate the camera interface
- Display area for the captured image
- Camera functionality integrated directly via UIViewControllerRepresentable
- Custom camera UI controls and interface

The ContentView.swift file now integrates multiple components:

1. **Main ContentView**: SwiftUI view that provides the primary app interface with:
   - State management for captured images (`@State private var capturedImage: UIImage?`)
   - Navigation structure and conditional UI based on capture state
   - Sheet presentation for the camera interface

2. **CustomCameraRepresentable**: A `UIViewControllerRepresentable` wrapper that bridges SwiftUI and UIKit:
   - Uses the Coordinator pattern to handle delegate callbacks
   - Passes state changes back to the parent SwiftUI view with @Binding
   - Creates and manages the lifecycle of CustomCameraViewController

3. **CustomCameraViewController**: A UIKit view controller that manages the camera:
   - Controls AVCaptureSession lifecycle (setup, start, stop)
   - Configures camera settings (flash, quality, etc.)
   - Manages UI elements (capture button, flash toggle, cancel button)
   - Handles photo capture and processing
   - Uses proper delegate pattern for communicating back to SwiftUI

### Info.plist
Configuration file that includes essential app metadata and permission declarations:
- Camera usage permission (`NSCameraUsageDescription`) required for analyzing room lighting

### Assets.xcassets
Contains all image resources, icons, and other visual assets used in the application.

### Package.swift
Defines external dependencies using Swift Package Manager:
- OpenAI Swift client for AI-powered plant recommendations
- Other framework dependencies will be added as implementation progresses

## Dependencies

The application relies on the following frameworks:
- **SwiftUI**: For building the user interface
- **UIKit**: For advanced camera functionality not easily available in SwiftUI
- **AVFoundation**: For camera access and photo capture
- **ARKit**: Will be used for AR visualization of plant placement
- **Core ML**: Will be used for on-device image processing
- **Vision**: Will be used for advanced image analysis
- **RealityKit**: Will be used for AR visualization
- **OpenAI API**: Will be used for plant recommendations based on lighting analysis

## Design Patterns and Principles

### SwiftUI Best Practices
- **View Structs**: UI components are implemented as structs conforming to the View protocol
- **State Management**: 
  - `@State` for local view state (capturedImage)
  - `@Binding` to pass mutable state to child views
  - `@Environment` for view dismissal and other environment values
- **UIViewControllerRepresentable**: Used to integrate UIKit components when SwiftUI alone is insufficient

### Camera Implementation
The camera implementation follows best practices for iOS development:
- **Lifecycle Management**: Camera sessions are properly started and stopped based on view lifecycle
- **Permission Handling**: Camera permissions are requested and handled appropriately
- **Resource Efficiency**: Memory and processing resources are managed carefully
- **Bridge Pattern**: UIKit and SwiftUI are bridged using standard Apple-recommended patterns
- **Delegate Pattern**: Used for communication between UIKit camera controller and SwiftUI

## Planned Architecture

As development progresses, the application will follow a modular architecture with separate components for:

1. **Camera Module**: Handling camera access and image capture (Implemented)
2. **Image Processing Module**: Analyzing light levels and room conditions
3. **AI Recommendation Module**: Integrating with OpenAI for plant suggestions
4. **AR Visualization Module**: Showing virtual representations of plants in the room
5. **Data Storage Module**: Managing user preferences and saved recommendations

Each module will be designed with clear interfaces to maintain separation of concerns and facilitate testing.