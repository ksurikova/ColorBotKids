//
//  HTTPImageService.swift
//  ColorBotKids
//
//  Created by ksurikova on 17.11.2025.
//
import Foundation
import SwiftUI

final class HTTPImageService: ImageGenerationService {
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

        // Build improved prompt
        let improvedPrompt = config.promptBuilder.makePrompt(from: prompt)

        // Build JSON body
        let body = config.requestBody(for: improvedPrompt)
        let bodyData = try JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = config.timeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(config.authorizationHeader, forHTTPHeaderField: "Authorization")
        request.httpBody = bodyData

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ImageGenerationError.invalidResponse
            }

            try handleHTTPResponse(httpResponse, data: data)

            guard
                let imageData = try config.parseResponseData(data),
                let image = UIImage(data: imageData)
            else {
                throw ImageGenerationError.noImageData
            }

            return image
        } catch let error as ImageGenerationError {
            throw error
        } catch {
            throw ImageGenerationError.networkError
        }
    }

    private func handleHTTPResponse(_ response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200 ... 299:
            return
        case 401:
            throw ImageGenerationError.unauthorized
        case 403:
            throw ImageGenerationError.accessRestricted
        case 429:
            throw ImageGenerationError.rateLimitExceeded
        default:
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("ImageGeneration Server Error [\(response.statusCode)]: \(json)")
            } else if let text = String(data: data, encoding: .utf8) {
                print("ImageGeneration Server Error [\(response.statusCode)]: \(text)")
            } else {
                print("ImageGeneration Server Error [\(response.statusCode)]")
            }
            throw ImageGenerationError.serverError(statusCode: response.statusCode)
        }
    }
}
