//
//  ImageGenerationConfig.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//
import Foundation

protocol ImageGenerationConfig {
    var apiKey: String { get }
    var endpoint: String { get }
    var timeout: TimeInterval { get }
    var promptBuilder: PromptBuilder { get }
    var model: String { get }
    var width: Int { get }
    var height: Int { get }
}

struct StabilityAIConfig: ImageGenerationConfig {
    let apiKey: String
    let endpoint = "https://api.stability.ai/v1/generation/stable-diffusion-xl-1024-v1-0/text-to-image"
    let timeout: TimeInterval = 60
    let promptBuilder: PromptBuilder = StabilityPromptBuilder()
    let model = "stable-diffusion-xl-1024-v1-0"
    let width = 1024
    let height = 1024
}

struct OpenAIConfig: ImageGenerationConfig {
    let apiKey: String
    let endpoint = "https://api.openai.com/v1/images/generations"
    let timeout: TimeInterval = 60
    let promptBuilder: PromptBuilder = OpenAIPromptBuilder()
    let model = "dall-e-3"
    let width = 1024
    let height = 1024
}

struct MockConfig: ImageGenerationConfig {
    let apiKey: String = "mock-key"
    let endpoint = "https://mock.api"
    let timeout: TimeInterval = 5
    let promptBuilder: PromptBuilder = MockPromptBuilder()
    let model = "mock-model"
    let width = 1024
    let height = 1024
}

extension ImageGenerationConfig {
    var authorizationHeader: String {
        // Default is Bearer
        "Bearer \(apiKey)"
    }

    // Build JSON body from prompt
    func requestBody(for prompt: String) -> [String: Any] {
        switch model {
        case "dall-e-3":
            return [
                "model": model,
                "prompt": prompt,
                "size": "\(width)x\(height)",
                "n": 1,
            ]
        default:
            // default StabilityAI style
            return [
                "text_prompts": [
                    ["text": prompt, "weight": 1],
                ],
                "cfg_scale": 7,
                "height": height,
                "width": width,
                "samples": 1,
                "steps": 30,
            ]
        }
    }

    // Parse base64 image from response
    func parseResponseData(_ data: Data) throws -> Data? {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        switch model {
        case "dall-e-3":
            if
                let dataArray = json?["data"] as? [[String: Any]],
                let first = dataArray.first,
                let b64 = first["b64_json"] as? String {
                return Data(base64Encoded: b64)
            }
        default:
            if
                let artifacts = json?["artifacts"] as? [[String: Any]],
                let first = artifacts.first,
                let b64 = first["base64"] as? String {
                return Data(base64Encoded: b64)
            }
        }
        return nil
    }
}
