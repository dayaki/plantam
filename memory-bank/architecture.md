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
│   ├── ContentView.swift   # Main view controller
│   ├── Info.plist          # App configuration and permissions
│   ├── Assets.xcassets     # Image assets and resources
│   └── Preview Content/    # SwiftUI preview assets
└── Package.swift           # Swift Package Manager configuration
```

## File Descriptions

### PlantamApp.swift
The main entry point for the application. Defines the `App` protocol implementation and sets up the primary scene.

### ContentView.swift
The main view of the application. Currently displays a welcome screen with a leaf icon and app name. Will be expanded to include camera access, image processing controls, and plant recommendations.

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
- **ARKit**: Will be used for AR visualization of plant placement
- **Core ML**: Will be used for on-device image processing
- **Vision**: Will be used for advanced image analysis
- **RealityKit**: Will be used for AR visualization
- **OpenAI API**: Will be used for plant recommendations based on lighting analysis

## Planned Architecture

As development progresses, the application will follow a modular architecture with separate components for:

1. **Camera Module**: Handling camera access and image capture
2. **Image Processing Module**: Analyzing light levels and room conditions
3. **AI Recommendation Module**: Integrating with OpenAI for plant suggestions
4. **AR Visualization Module**: Showing virtual representations of plants in the room
5. **Data Storage Module**: Managing user preferences and saved recommendations

Each module will be designed with clear interfaces to maintain separation of concerns and facilitate testing.