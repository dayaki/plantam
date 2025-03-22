import Foundation
import UIKit

// MARK: - Models

struct PlantRecommendations: Codable {
    var recommendations: [PlantRecommendation] = []
}

struct PlantRecommendation: Codable, Identifiable {
    var id = UUID()
    var commonName: String
    var scientificName: String
    var careInstructions: String
    var suitabilityReason: String
    
    enum CodingKeys: String, CodingKey {
        case commonName, scientificName, careInstructions, suitabilityReason
    }
    
    init(commonName: String, scientificName: String, careInstructions: String, suitabilityReason: String) {
        self.commonName = commonName
        self.scientificName = scientificName
        self.careInstructions = careInstructions
        self.suitabilityReason = suitabilityReason
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        commonName = try container.decode(String.self, forKey: .commonName)
        scientificName = try container.decode(String.self, forKey: .scientificName)
        careInstructions = try container.decode(String.self, forKey: .careInstructions)
        suitabilityReason = try container.decode(String.self, forKey: .suitabilityReason)
    }
}

// MARK: - Errors

enum OpenAIServiceError: Error {
    case imageEncodingFailed
    case emptyResponse
    case jsonParsingFailed
}