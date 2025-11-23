//
//  StabilityImageService.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//
import Foundation
import SwiftUI

// delete then
class StabilityAIImageService: ImageGenerationService {
    private let config: ImageGenerationConfig
    private let session: URLSession = .shared

    init(config: ImageGenerationConfig) {
        self.config = config
    }

    func generateImage(from prompt: String) async throws -> UIImage {
        guard !config.apiKey.isEmpty else {
            throw ImageGenerationError.invalidAPIKey
        }
        guard let url = URL(string: config.endpoint) else {
            throw ImageGenerationError.invalidURL
        }
        // make prompt more good-looking
        let improvedPrompt = config.promptBuilder.makePrompt(from: prompt)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = config.timeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(config.apiKey, forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "text_prompts": [
                ["text": improvedPrompt, "weight": 1],
            ],
            "cfg_scale": 7,
            "height": config.height,
            "width": config.width,
            "samples": 1,
            "steps": 30,
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ImageGenerationError.invalidResponse
            }
            try handleHTTPResponse(httpResponse, data: data)

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let artifacts = json["artifacts"] as? [[String: Any]],
                  let firstArtifact = artifacts.first,
                  let base64String = firstArtifact["base64"] as? String,
                  let imageData = Data(base64Encoded: base64String),
                  let image = UIImage(data: imageData)
            else {
                throw ImageGenerationError.noImageData
            }
            return image
        } catch let error as ImageGenerationError {
            throw error
        } catch {
            throw ImageGenerationError.networkError(error)
        }
    }

    private func handleHTTPResponse(_ response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200 ... 299:
            return
        case 429:
            throw ImageGenerationError.rateLimitExceeded
        default:
            let message = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            let errorMsg = message?["message"] as? String
            throw ImageGenerationError.serverError(
                statusCode: response.statusCode,
                message: errorMsg
            )
        }
    }
}
