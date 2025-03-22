import Foundation
import OpenAI
import UIKit

// Import LightLevel from the other file by referring to it directly
// No need to redeclare the enum

class OpenAIService {
    private let client: OpenAI
    
    // MARK: - Initialization
    
    init() {
        // Initialize with API key from environment
        let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ??
                     Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String ?? ""
        
        if apiKey.isEmpty {
            fatalError("OpenAI API key not found. Please set OPENAI_API_KEY in environment or Info.plist")
        }
        
        let configuration = OpenAI.Configuration(token: apiKey)
        self.client = OpenAI(configuration: configuration)
    }
    
    // MARK: - Public Methods
    
    /// Get plant recommendations based on lighting conditions
    /// - Parameters:
    ///   - image: The room image to analyze
    ///   - lightLevel: The detected light level
    ///   - completion: Callback with recommendations or error
    func getPlantRecommendations(
        image: UIImage,
        lightLevel: LightLevel,
        completion: @escaping (Result<PlantRecommendations, Error>) -> Void
    ) {
        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: 0.7),
              let base64String = imageData.base64EncodedString() as String? else {
            completion(.failure(OpenAIServiceError.imageEncodingFailed))
            return
        }
        
        // Create the prompt based on light level
        let prompt = createPrompt(for: lightLevel)
        
        // Create the chat request
        let imgParam = ChatQuery.ChatCompletionMessageParam.ChatCompletionUserMessageParam(content: 
            .vision([
                .text(prompt),
                .chatCompletionContentPartImageParam(.init(imageUrl: .init(url: base64String, detail: .high)))
            ])
        )
        
//        let query = ChatQuery(
//            messages: [.user(imgParam)],
//            model: "gpt-4-vision-preview",
//            maxTokens: 500
//        )
        let query = ChatQuery(messages: [
            .user(imgParam),
            .user(.init(content: .string(prompt)))
        ],
                              model: .gpt4_o,
                              maxTokens: 500)
        
        // Send the request
        client.chats(query: query) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if let content = response.choices.first?.message.content {
                    do {
                        // Parse the response
                        let recommendations = try self.parseRecommendations(from: content)
                        completion(.success(recommendations))
                    } catch {
                        print("Error parsing OpenAI response: \(error)")
                        completion(.success(self.fallbackRecommendations(for: lightLevel)))
                    }
                } else {
                    completion(.failure(OpenAIServiceError.emptyResponse))
                }
                
            case .failure(let error):
                print("OpenAI API error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func createPrompt(for lightLevel: LightLevel) -> String {
        // Convert the LightLevel enum to a string format appropriate for the prompt
        let lightLevelString: String
        switch lightLevel {
        case .low:
            lightLevelString = "low light"
        case .medium:
            lightLevelString = "medium light"
        case .high:
            lightLevelString = "bright light"
        }
        
        return """
        I need plant recommendations for a room with \(lightLevelString) conditions.
        
        Based on the image and the lighting level (\(lightLevelString)), please recommend 5 plants that would thrive in this environment.
        
        For each plant, provide:
        1. Common name
        2. Scientific name
        3. Brief care instructions (watering, soil, etc.)
        4. A short description of why it's suitable for this lighting condition
        
        Format your response as a JSON object with this structure:
        {
          "recommendations": [
            {
              "commonName": "Plant name",
              "scientificName": "Scientific name",
              "careInstructions": "Care details",
              "suitabilityReason": "Why it's suitable"
            },
            ...
          ]
        }
        
        Only respond with the JSON object, no other text.
        """
    }
    
    private func parseRecommendations(from response: String) throws -> PlantRecommendations {
        // Try to extract JSON if it's wrapped in markdown code blocks
        let jsonString: String
        if response.contains("```json") && response.contains("```") {
            let components = response.components(separatedBy: "```json")
            if components.count > 1 {
                let jsonPart = components[1].components(separatedBy: "```")[0]
                jsonString = jsonPart.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                jsonString = response
            }
        } else if response.contains("```") {
            let components = response.components(separatedBy: "```")
            if components.count > 1 {
                jsonString = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                jsonString = response
            }
        } else {
            jsonString = response
        }
        
        // Parse the JSON
        guard let data = jsonString.data(using: .utf8) else {
            throw OpenAIServiceError.jsonParsingFailed
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(PlantRecommendations.self, from: data)
        } catch {
            print("JSON parsing error: \(error)")
            throw OpenAIServiceError.jsonParsingFailed
        }
    }
    
    /// Provides fallback plant recommendations when the API call fails
    /// - Parameter lightLevel: The detected light level
    /// - Returns: Default plant recommendations for the given light level
    func fallbackRecommendations(for lightLevel: LightLevel) -> PlantRecommendations {
        // Provide fallback recommendations if API fails
        var recommendations = PlantRecommendations()
        
        switch lightLevel {
        case .low:
            recommendations.recommendations = [
                PlantRecommendation(
                    commonName: "Snake Plant",
                    scientificName: "Sansevieria trifasciata",
                    careInstructions: "Water every 2-3 weeks, allow soil to dry completely between waterings.",
                    suitabilityReason: "Extremely tolerant of low light conditions and neglect."
                ),
                PlantRecommendation(
                    commonName: "ZZ Plant",
                    scientificName: "Zamioculcas zamiifolia",
                    careInstructions: "Water sparingly, only when soil is completely dry.",
                    suitabilityReason: "Thrives in low light and is very drought tolerant."
                ),
                PlantRecommendation(
                    commonName: "Peace Lily",
                    scientificName: "Spathiphyllum",
                    careInstructions: "Keep soil consistently moist but not soggy.",
                    suitabilityReason: "One of the few flowering plants that can bloom in low light."
                )
            ]
            
        case .medium:
            recommendations.recommendations = [
                PlantRecommendation(
                    commonName: "Pothos",
                    scientificName: "Epipremnum aureum",
                    careInstructions: "Allow top inch of soil to dry between waterings.",
                    suitabilityReason: "Adaptable to various light conditions, perfect for medium light."
                ),
                PlantRecommendation(
                    commonName: "Spider Plant",
                    scientificName: "Chlorophytum comosum",
                    careInstructions: "Keep soil lightly moist, tolerates occasional drying out.",
                    suitabilityReason: "Thrives in medium indirect light and produces plantlets."
                ),
                PlantRecommendation(
                    commonName: "Philodendron",
                    scientificName: "Philodendron hederaceum",
                    careInstructions: "Water when top inch of soil is dry.",
                    suitabilityReason: "Adaptable to medium light and easy to care for."
                )
            ]
            
        case .high:
            recommendations.recommendations = [
                PlantRecommendation(
                    commonName: "Fiddle Leaf Fig",
                    scientificName: "Ficus lyrata",
                    careInstructions: "Water when top 2 inches of soil are dry, rotate regularly for even growth.",
                    suitabilityReason: "Thrives in bright, indirect light and makes a dramatic statement."
                ),
                PlantRecommendation(
                    commonName: "Succulents",
                    scientificName: "Various",
                    careInstructions: "Water sparingly, only when soil is completely dry.",
                    suitabilityReason: "Perfect for bright light conditions, drought-tolerant."
                ),
                PlantRecommendation(
                    commonName: "Bird of Paradise",
                    scientificName: "Strelitzia nicolai",
                    careInstructions: "Keep soil consistently moist in growing season, less in winter.",
                    suitabilityReason: "Loves bright light and adds a tropical feel to any space."
                )
            ]
        }
        
        return recommendations
    }
}

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
