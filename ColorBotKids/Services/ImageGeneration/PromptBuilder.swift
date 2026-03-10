//
//  PromptBuilder.swift
//  ColorBotKids
//
//  Created by ksurikova on 15.10.2025.
//
import Foundation

protocol PromptBuilder {
    func makePrompt(from userPrompt: String) -> String
}

extension PromptBuilder {
    func sanitizeInput(_ text: String) -> String {
        let disallowed = CharacterSet(charactersIn: "\"'`$<>")
        return text
            .components(separatedBy: disallowed)
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

final class StabilityPromptBuilder: PromptBuilder {
    func makePrompt(from userPrompt: String) -> String {
        let cleaned = sanitizeInput(userPrompt)

        return """
        A clean black-and-white line drawing of \(cleaned), coloring book style, \
        simple outlines, no shading, no color, vector line art, white background, \
        suitable for kids to color.
        """
    }
}

final class OpenAIPromptBuilder: PromptBuilder {
    func makePrompt(from userPrompt: String) -> String {
        let cleaned = sanitizeInput(userPrompt)
        return """
        Create a simple black and white coloring page of \(cleaned). \
        The image should have clear outlines, no shading, and be suitable for children to color.
        """
    }
}

final class MockPromptBuilder: PromptBuilder {
    func makePrompt(from userPrompt: String) -> String {
        "[MOCK] \(sanitizeInput(userPrompt))"
    }
}
