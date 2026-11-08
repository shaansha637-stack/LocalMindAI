import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: ChatStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Local model") {
                    Picker("Model", selection: $store.modelID) {
                        ForEach(store.modelChoices, id: \.self) { id in
                            Text(id.components(separatedBy: "/").last ?? id).tag(id)
                        }
                    }
                    Text(store.modelID)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        Button("Load selected model") {
                            Task { await store.loadModel() }
                        }
                        .disabled(store.isLoading)
                }

                Section("Assistant instructions") {
                    TextEditor(text: $store.systemPrompt)
                        .frame(minHeight: 120)
                    Text("This prompt guides the model. The model's own training and behavior still apply.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Generation") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Temperature")
                            Spacer()
                            Text(store.temperature, format: .number.precision(.fractionLength(2)))
                                .monospacedDigit()
                        }
                        Slider(value: $store.temperature, in: 0.1...1.5, step: 0.05)
                    }
                    Stepper("Maximum tokens: \(store.maxTokens)", value: $store.maxTokens, in: 128...2048, step: 128)
                }

                Section("Appearance & data") {
                    Toggle("Dark appearance", isOn: $store.darkMode)
                    Button("Clear chat history", role: .destructive) {
                        store.clearChat()
                    }
                }

                Section {
                    Text("Inference runs on-device with MLX. The model is downloaded from Hugging Face and cached locally. No prompt is sent to a cloud AI API by this app.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
