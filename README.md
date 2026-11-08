# LocalMind AI — Native iOS, on-device LLM

A SwiftUI chat app that runs a quantized language model **on the iPhone** using Apple's Metal backend through MLX Swift. No cloud inference API or account is required. The first model download requires internet; after the model is cached, text generation runs locally.

> This is a starter repository, not a prebuilt IPA. GitHub Actions compiles an unsigned IPA. Import the IPA into Feather and sign it on-device before installation.

## Included

- Native SwiftUI chat UI
- Local model download and caching via Hugging Face
- Two selectable MLX model IDs (small models intended for mobile experimentation)
- Editable system prompt, temperature, and maximum output tokens
- Local chat history using `UserDefaults`
- Clear conversation and model reload
- GitHub Actions workflow: `.github/workflows/ios-unsigned.yml`

## Requirements and expectations

- iPhone with an Apple GPU / Metal support and enough free memory for the selected model. Compatibility and speed vary by iPhone model.
- iOS 17 or later.
- Internet for the initial model download. Model files can be several hundred MB or more.
- The app bundle does **not** include model weights. This keeps the GitHub ZIP and IPA reasonably small.
- Local inference does not mean the model is literally unrestricted: model training, its own refusal behavior, applicable law, and the model publisher's license still apply. The app adds no separate moderation layer to ordinary prompts.
- Check each model card and license on Hugging Face before redistributing or using it.

## Default models

1. `mlx-community/Qwen3-0.6B-4bit` — small quantized model for initial testing.
2. `mlx-community/Llama-3.2-1B-Instruct-4bit` — alternative small quantized model.

Model availability, memory use, and license terms can change. If a model repository is renamed or unavailable, choose a compatible MLX-converted model and enter its Hugging Face repository ID in Settings.

## Build from iPhone using GitHub

1. Download and extract this ZIP on your iPhone.
2. Create a new **public or private** GitHub repository.
3. Upload the extracted files and folders, preserving their paths. GitHub's web interface can create folders by typing `/` in a new file path; for many files, uploading the extracted folder from Files is easier if your browser supports folder upload.
4. Confirm that `.github/workflows/ios-unsigned.yml` is present.
5. Open **Actions** → **Build unsigned iOS IPA** → **Run workflow**.
6. Wait for the workflow to finish. Download the `LocalMindAI-unsigned-ipa` artifact.
7. Extract the artifact ZIP to get `LocalMindAI.ipa`.
8. Open/import that IPA in Feather, sign it with your certificate, then install it.

No Apple Developer account or Mac is needed to edit the repository. GitHub-hosted macOS runners perform the build. The resulting IPA is intentionally unsigned; it must be re-signed for installation.

## Model setup on the iPhone

1. Open LocalMind AI.
2. Tap **Load model**. Keep the app open while the model downloads.
3. Once loading completes, send a message. The first response may take longer while the model initializes.
4. For offline use after the first download, keep the model cached and test with Airplane Mode enabled.

## Troubleshooting

- **Build fails during Swift package resolution:** rerun the workflow. If it persists, inspect the first package-resolution error in the Actions log; upstream MLX dependencies can change.
- **Model load fails:** check the Hugging Face model ID, internet connection, available storage, and model card compatibility.
- **App closes or memory warning:** select the smaller model, close other apps, and retry. Not every iPhone can run every model.
- **Very slow output:** local generation speed depends heavily on the iPhone chip, memory pressure, model size, and context length.
- **Feather says the IPA is unsigned:** that is expected. Sign it in Feather before installing.

## Project layout

```text
LocalMindAI/
├── .github/workflows/ios-unsigned.yml
├── LocalMindAI/
│   ├── LocalMindAIApp.swift
│   ├── Models/ChatMessage.swift
│   ├── Services/LocalLLMService.swift
│   ├── Stores/ChatStore.swift
│   ├── Views/ChatView.swift
│   ├── Views/SettingsView.swift
│   └── Info.plist
├── project.yml
├── .gitignore
└── README.md
```

## License

The app source in this repository is provided under the MIT License. Third-party libraries and downloaded model weights retain their own licenses.
