import Foundation
import MLXLLM
import MLXLMCommon
import MLXHuggingFace
import HuggingFace
import Tokenizers

@MainActor
final class LocalLLMService {
    private var modelContainer: ModelContainer?
    private var session: ChatSession?
    private(set) var isLoaded = false

    func load(modelID: String) async throws {
        isLoaded = false
        session = nil
        modelContainer = nil

        let container = try await loadModelContainer(
            from: #hubDownloader(),
            using: #huggingFaceTokenizerLoader(),
            id: modelID
        )
        modelContainer = container
        session = ChatSession(container)
        isLoaded = true
    }

    func respond(
        to prompt: String,
        systemPrompt: String,
        temperature: Double,
        maxTokens: Int
    ) async throws -> String {
        guard let modelContainer else {
            throw LocalAIError.modelNotLoaded
        }

        // A fresh session applies the current system prompt consistently.
        // The conversation transcript is maintained by the app UI; this
        // initial implementation sends the latest user turn plus system prompt.
        let chat = ChatSession(
            modelContainer,
            instructions: systemPrompt,
            generateParameters: GenerateParameters(
                temperature: Float(temperature),
                maxTokens: maxTokens
            )
        )
        return try await chat.respond(to: prompt)
    }
}

enum LocalAIError: LocalizedError {
    case modelNotLoaded

    var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "No model is loaded. Tap Load model in the header."
        }
    }
}
