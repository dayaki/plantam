import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

enum LightLevel: String, CaseIterable {
    case low = "Low Light"
    case medium = "Medium Light"
    case high = "High Light"
    
    var description: String {
        switch self {
        case .low:
            return "Perfect for shade-loving plants like Snake Plants, ZZ Plants, and Peace Lilies."
        case .medium:
            return "Great for plants that prefer indirect light such as Pothos, Philodendrons, and Spider Plants."
        case .high:
            return "Ideal for sun-loving plants like Succulents, Cacti, and Fiddle Leaf Figs."
        }
    }
    
    var icon: String {
        switch self {
        case .low:
            return "light.min"
        case .medium:
            return "light.max"
        case .high:
            return "sun.max.fill"
        }
    }
    
    var color: UIColor {
        switch self {
        case .low:
            return UIColor(red: 0.3, green: 0.5, blue: 0.7, alpha: 1.0) // Blue-ish
        case .medium:
            return UIColor(red: 0.9, green: 0.7, blue: 0.0, alpha: 1.0) // Amber
        case .high:
            return UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0) // Orange
        }
    }
}

struct LightingZone {
    var level: LightLevel
    var percentage: Double
    var region: CGRect // Normalized rect (0.0-1.0) representing the zone's position in the image
}

class LightingAnalyzer {
    private let context = CIContext()
    
    // Thresholds for determining light levels (0-255)
    private let lowLightThreshold: Float = 85
    private let highLightThreshold: Float = 170
    
    // Analyze the overall lighting of an image
    func analyzeOverallLighting(image: UIImage) -> LightLevel {
        let averageBrightness = calculateAverageBrightness(image: image)
        
        if averageBrightness < lowLightThreshold {
            return .low
        } else if averageBrightness < highLightThreshold {
            return .medium
        } else {
            return .high
        }
    }
    
    // Identify different lighting zones within an image
    func identifyLightingZones(image: UIImage, gridSize: Int = 3) -> [LightingZone] {
        guard let cgImage = image.cgImage else { return [] }
        
        let width = cgImage.width
        let height = cgImage.height
        
        var zones: [LightingZone] = []
        
        // Divide the image into a grid and analyze each cell
        let cellWidth = width / gridSize
        let cellHeight = height / gridSize
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let rect = CGRect(
                    x: col * cellWidth,
                    y: row * cellHeight,
                    width: cellWidth,
                    height: cellHeight
                )
                
                if let cellImage = cgImage.cropping(to: rect) {
                    let uiCellImage = UIImage(cgImage: cellImage)
                    let brightness = calculateAverageBrightness(image: uiCellImage)
                    
                    let lightLevel: LightLevel
                    if brightness < lowLightThreshold {
                        lightLevel = .low
                    } else if brightness < highLightThreshold {
                        lightLevel = .medium
                    } else {
                        lightLevel = .high
                    }
                    
                    // Create a normalized rect (0.0-1.0) for the zone
                    let normalizedRect = CGRect(
                        x: CGFloat(col) / CGFloat(gridSize),
                        y: CGFloat(row) / CGFloat(gridSize),
                        width: 1.0 / CGFloat(gridSize),
                        height: 1.0 / CGFloat(gridSize)
                    )
                    
                    let zone = LightingZone(
                        level: lightLevel,
                        percentage: 100.0 / Double(gridSize * gridSize),
                        region: normalizedRect
                    )
                    
                    zones.append(zone)
                }
            }
        }
        
        return zones
    }
    
    // Calculate the average brightness of an image (0-255)
    private func calculateAverageBrightness(image: UIImage) -> Float {
        guard let inputImage = CIImage(image: image) else { return 0 }
        
        // Convert to grayscale
        let grayscaleFilter = CIFilter.colorControls()
        grayscaleFilter.inputImage = inputImage
        grayscaleFilter.saturation = 0 // Remove color
        
        guard let grayscaleImage = grayscaleFilter.outputImage else { return 0 }
        
        // Calculate average brightness
        // let extentVector = CIVector(
        //     x: grayscaleImage.extent.origin.x,
        //     y: grayscaleImage.extent.origin.y,
        //     z: grayscaleImage.extent.size.width,
        //     w: grayscaleImage.extent.size.height
        // )
        let extentRect = grayscaleImage.extent
        
        let averageFilter = CIFilter.areaAverage()
        averageFilter.inputImage = grayscaleImage
        averageFilter.extent = extentRect
        
        guard let outputImage = averageFilter.outputImage else { return 0 }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(outputImage,
                      toBitmap: &bitmap,
                      rowBytes: 4,
                      bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                      format: .RGBA8,
                      colorSpace: nil)
        
        // Average of RGB components (ignoring alpha)
        // Convert each UInt8 to Float before addition to prevent overflow
        let brightness = (Float(bitmap[0]) + Float(bitmap[1]) + Float(bitmap[2])) / 3.0
        
        return brightness
    }
    
    // Generate a visualization of the lighting zones
    func generateZoneVisualization(image: UIImage, zones: [LightingZone]) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        
        // Draw the original image
        image.draw(at: .zero)
        
        // Draw overlays for each zone
        for zone in zones {
            let rect = CGRect(
                x: zone.region.origin.x * image.size.width,
                y: zone.region.origin.y * image.size.height,
                width: zone.region.width * image.size.width,
                height: zone.region.height * image.size.height
            )
            
            // Draw a semi-transparent overlay with the zone's color
            let color = zone.level.color.withAlphaComponent(0.3)
            color.setFill()
            UIRectFillUsingBlendMode(rect, .normal)
            
            // Add a label for the light level
            let label = zone.level.rawValue
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 12),
                .foregroundColor: UIColor.white,
                .strokeColor: UIColor.black,
                .strokeWidth: -2.0
            ]
            
            let labelSize = (label as NSString).size(withAttributes: attributes)
            let labelRect = CGRect(
                x: rect.midX - labelSize.width / 2,
                y: rect.midY - labelSize.height / 2,
                width: labelSize.width,
                height: labelSize.height
            )
            
            (label as NSString).draw(in: labelRect, withAttributes: attributes)
        }
        
        let visualizationImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return visualizationImage ?? image
    }
    
    // Get a summary of the lighting analysis
    func getLightingSummary(zones: [LightingZone]) -> [LightLevel: Double] {
        var summary: [LightLevel: Double] = [:]
        
        for level in LightLevel.allCases {
            let zonesWithLevel = zones.filter { $0.level == level }
            let percentage = zonesWithLevel.reduce(0.0) { $0 + $1.percentage }
            summary[level] = percentage
        }
        
        return summary
    }
}
