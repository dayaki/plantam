Key Features & Technical Implementation:

1. Light Detection from Room Photos
   The app should analyze the brightness of different areas in the photo to determine ideal plant placement.
   Technical Approach:
   Use AVCaptureDevice to access real-time light levels when taking a photo.
   Process the captured image using Core Image (CIFilter, CIColorControls, CIVector) to extract brightness levels.
   Optional: Use Vision Framework for advanced image processing and segmentation.
2. AI-Powered Plant Recommendations
   Based on the detected lighting conditions, the app should suggest plant species that will thrive in that environment.
   Technical Approach:
   Use Core ML for on-device AI-based plant recommendations.
   Alternatively, call OpenAI’s Vision API to analyze the image and return plant suggestions.
   Store plant details in a local database (Core Data/SQLite) or fetch from an API (Supabase or Firebase).
3. Augmented Reality (AR) for Plant Placement
   Users should be able to place virtual plants in their room using AR.
   Technical Approach:
   Use ARKit to track the room’s environment and surface detection.
   Use RealityKit or SceneKit to render 3D plant models that can be moved and resized in AR.
   Allow users to interact with the plants (e.g., rotating, scaling).
4. User Authentication & Data Storage
   Users should be able to save their favorite plant placements and recommendations.
   Technical Approach:
   Use Firebase/Auth0 for login/sign-up (or Sign in with Apple).
   Use Core Data or CloudKit to store user preferences.
   User Flow:
   User takes a photo of their room.
   App analyzes the lighting conditions using Core Image.
   AI suggests best plant options based on brightness.
   User can view and place plants in AR using ARKit.
   User can save recommendations or share them.
   Tech Stack Summary:
   Feature Technology
   Camera Access AVCaptureDevice (iOS Camera API)
   Image Processing (Light Analysis) Core Image (CIFilter)
   AI Recommendations Core ML / OpenAI API
   Augmented Reality (AR) ARKit + RealityKit
   User Authentication Firebase/Auth0
   Database (Plant Info & User Data) Core Data / CloudKit
   Deliverables Expected from the Developer:
   iOS app written in Swift (Objective-C if necessary).
   Full integration of AI, AR, and image processing as outlined above.
   Clean, modular, and well-documented codebase.
   An MVP version that can analyze room brightness, suggest plants, and visualize them in AR.
   Additional Notes:
   The app should prioritize performance (low latency for AR and image processing).
   It should have a clean, user-friendly UI.
   Future updates may include voice interaction for AI-based plant care guidance.
