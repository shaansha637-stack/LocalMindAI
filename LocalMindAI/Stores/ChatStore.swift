import Foundation
import SwiftUI

@MainActor
final class ChatStore: ObservableObject {
    @Published var messages: [ChatMessage] = [] {
        didSet { saveHistory() }
    }
    @Published var input = ""
    @Published var isLoading = false
    @Published var status = "Model not loaded"
    @Published var errorMessage: String?
    @Published var modelID: String {
        didSet { UserDefaults.standard.set(modelID, forKey: "modelID") }
    }
    @Published var systemPrompt: String {
        didSet { UserDefaults.standard.set(systemPrompt, forKey: "systemPrompt") }
    }
    @Published var temperature: Double {
        didSet { UserDefaults.standard.set(temperature, forKey: "temperature") }
    }
    @Published var maxTokens: Int {
        didSet { UserDefaults.standard.set(maxTokens, forKey: "maxTokens") }
    }
    @Published var darkMode: Bool {
        didSet { UserDefaults.standard.set(darkMode, forKey: "darkMode") }
    }

    let modelChoices = [
        "mlx-community/Qwen3-0.6B-4bit",
        "mlx-community/Llama-3.2-1B-Instruct-4bit"
    ]

    let llm = LocalLLMService()

    init() {
        modelID = UserDefaults.standard.string(forKey: "modelID")
            ?? "mlx-community/Qwen3-0.6B-4bit"
        systemPrompt = UserDefaults.standard.string(forKey: "systemPrompt")
            ?? "You are a helpful, honest assistant. Answer clearly and thoughtfully."
        temperature = UserDefaults.standard.object(forKey: "temperature") as? Double ?? 0.7
        maxTokens = UserDefaults.standard.object(forKey: "maxTokens") as? Int ?? 512
        darkMode = UserDefaults.standard.object(forKey: "darkMode") as? Bool ?? true
        if let data = UserDefaults.standard.data(forKey: "chatHistory"),
           let decoded = try? JSONDecoder().decode([ChatMessage].self, from: data) {
            messages = decoded
        }
    }

    func loadModel() async {
        isLoading = true
        errorMessage = nil
        status = "Downloading / loading model…"
        do {
            try await llm.load(modelID: modelID)
            status = "Ready · running on this iPhone"
        } catch {
            status = "Model load failed"
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func send() async {
        let prompt = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty, !isLoading else { return }
        guard llm.isLoaded else {
            errorMessage = "Load a model first."
            return
        }

        input = ""
        messages.append(ChatMessage(role: .user, text: prompt))
        isLoading = true
        errorMessage = nil
        status = "Generating locally…"

        do {
            let answer = try await llm.respond(
                to: prompt,
                systemPrompt: systemPrompt,
                temperature: temperature,
                maxTokens: maxTokens
            )
            messages.append(ChatMessage(role: .assistant, text: answer))
            status = "Ready · running on this iPhone"
        } catch {
            errorMessage = error.localizedDescription
            status = "Generation failed"
        }
        isLoading = false
    }

    func clearChat() {
        messages.removeAll()
    }

    private func saveHistory() {
        guard let data = try? JSONEncoder().encode(messages) else { return }
        UserDefaults.standard.set(data, forKey: "chatHistory")
    }
}
