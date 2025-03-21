import SwiftUI
import UIKit
import AVFoundation

struct ContentView: View {
    @State private var capturedImage: UIImage?
    @State private var showingCameraSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let image = capturedImage {
                    // Top close button for captured image view
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            capturedImage = nil
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                                .padding(.trailing, 8)
                                .padding(.top, 8)
                        }
                    }
                    
                    // Display captured image
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom)
                        .shadow(radius: 3)
                } else {
                    // Welcome screen
                    VStack(spacing: 20) {
                        Image(systemName: "leaf.fill")
                            .imageScale(.large)
                            .foregroundStyle(.green)
                            .font(.system(size: 60))
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.green.opacity(0.2))
                                    .frame(width: 120, height: 120)
                            )
                        
                        Text("Welcome to Plantam")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Your iOS Plant Placement Assistant")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 20)
                        
                        Text("Take a photo of your room to get started with plant recommendations based on lighting analysis.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 30)
                    }
                    .padding()
                }
                
                Button(action: {
                    showingCameraSheet = true
                }) {
                    HStack {
                        Image(systemName: capturedImage == nil ? "camera.fill" : "arrow.clockwise")
                        Text(capturedImage == nil ? "Take Photo" : "Take New Photo")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                if capturedImage != nil {
                    Button(action: {
                        // This would be replaced with actual analysis functionality in Step 3
                        print("Analyzing image lighting...")
                    }) {
                        HStack {
                            Image(systemName: "light.max")
                            Text("Analyze Room Lighting")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Plantam")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingCameraSheet) {
                CustomCameraRepresentable(capturedImage: $capturedImage, isPresented: $showingCameraSheet)
                    .edgesIgnoringSafeArea(.all)
                    .presentationDetents([.height(700), .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

// A UIViewControllerRepresentable wrapper for a custom camera
struct CustomCameraRepresentable: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> CustomCameraViewController {
        let controller = CustomCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CustomCameraViewController, context: Context) {
        // No update needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CustomCameraViewControllerDelegate {
        let parent: CustomCameraRepresentable
        
        init(_ parent: CustomCameraRepresentable) {
            self.parent = parent
        }
        
        func didCaptureImage(_ image: UIImage) {
            parent.capturedImage = image
            parent.isPresented = false
        }
        
        func didCancel() {
            parent.isPresented = false
        }
    }
}

// Protocol for camera view controller delegate
protocol CustomCameraViewControllerDelegate: AnyObject {
    func didCaptureImage(_ image: UIImage)
    func didCancel()
}

// Custom camera implementation using UIKit
class CustomCameraViewController: UIViewController {
    weak var delegate: CustomCameraViewControllerDelegate?
    
    // Camera components
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let photoOutput = AVCapturePhotoOutput()
    
    // UI components
    private let captureButton = UIButton(type: .system)
    private let flashButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    
    private var flashMode: AVCaptureDevice.FlashMode = .auto
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCameraSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCameraSession()
    }
    
    private func startCameraSession() {
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }
    
    private func stopCameraSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    private func setupCamera() {
        captureSession.sessionPreset = .photo
        
        // Get the back camera
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoDeviceInput) else {
            print("Failed to get camera input")
            return
        }
        
        captureSession.addInput(videoDeviceInput)
        
        // Set up photo output
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.maxPhotoQualityPrioritization = .quality
        }
        
        // Set up preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Add preview layer to view
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        // Configure capture button
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        captureButton.tintColor = .white
        captureButton.contentVerticalAlignment = .fill
        captureButton.contentHorizontalAlignment = .fill
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        
        // Configure flash button
        flashButton.translatesAutoresizingMaskIntoConstraints = false
        flashButton.setImage(UIImage(systemName: "bolt.badge.a.fill"), for: .normal)
        flashButton.tintColor = .white
        flashButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        flashButton.layer.cornerRadius = 20
        flashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        
        // Configure cancel button
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        cancelButton.tintColor = .white
        cancelButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        cancelButton.layer.cornerRadius = 20
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        // Add buttons to view
        view.addSubview(captureButton)
        view.addSubview(flashButton)
        view.addSubview(cancelButton)
        
        // Set up constraints for capture button
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        // Set up constraints for flash button
        NSLayoutConstraint.activate([
            flashButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            flashButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            flashButton.widthAnchor.constraint(equalToConstant: 40),
            flashButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Set up constraints for cancel button
        NSLayoutConstraint.activate([
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cancelButton.widthAnchor.constraint(equalToConstant: 40),
            cancelButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc private func toggleFlash() {
        switch flashMode {
        case .auto:
            flashMode = .on
            flashButton.setImage(UIImage(systemName: "bolt.fill"), for: .normal)
        case .on:
            flashMode = .off
            flashButton.setImage(UIImage(systemName: "bolt.slash.fill"), for: .normal)
        case .off:
            flashMode = .auto
            flashButton.setImage(UIImage(systemName: "bolt.badge.a.fill"), for: .normal)
        @unknown default:
            flashMode = .auto
            flashButton.setImage(UIImage(systemName: "bolt.badge.a.fill"), for: .normal)
        }
    }
    
    @objc private func cancel() {
        delegate?.didCancel()
    }
    
    // Handle device orientation changes
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            self.previewLayer.frame = CGRect(origin: .zero, size: size)
            
            if let connection = self.previewLayer.connection {
                let orientation = self.view.window?.windowScene?.interfaceOrientation ?? .portrait
                
                switch orientation {
                case .portrait:
                    connection.videoOrientation = .portrait
                case .landscapeLeft:
                    connection.videoOrientation = .landscapeLeft
                case .landscapeRight:
                    connection.videoOrientation = .landscapeRight
                case .portraitUpsideDown:
                    connection.videoOrientation = .portraitUpsideDown
                default:
                    connection.videoOrientation = .portrait
                }
            }
        })
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CustomCameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Unable to create image from photo data")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.didCaptureImage(image)
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
