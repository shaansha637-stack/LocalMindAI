import SwiftUI

struct ChatView: View {
    @EnvironmentObject private var store: ChatStore
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                statusBar
                if store.messages.isEmpty {
                    emptyState
                } else {
                    messageList
                }
                composer
            }
            .navigationTitle("LocalMind AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        store.clearChat()
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .accessibilityLabel("New chat")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(store)
            }
            .alert("Local AI", isPresented: Binding(
                get: { store.errorMessage != nil },
                set: { if !$0 { store.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { store.errorMessage = nil }
            } message: {
                Text(store.errorMessage ?? "")
            }
        }
    }

    private var statusBar: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(store.llm.isLoaded ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            Text(store.status)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Spacer()
            if !store.llm.isLoaded {
                Button("Load model") {
                    Task { await store.loadModel() }
                }
                .font(.caption.weight(.semibold))
                .buttonStyle(.borderedProminent)
                .disabled(store.isLoading)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            Text("Your AI. On your iPhone.")
                .font(.title2.bold())
            Text("Download a compatible model once. After that, chats are generated locally without a cloud AI API.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 28)
            Button {
                Task { await store.loadModel() }
            } label: {
                Label("Load local model", systemImage: "arrow.down.circle")
            }
            .buttonStyle(.borderedProminent)
            .disabled(store.isLoading)
            if store.isLoading {
                ProgressView("Preparing model…")
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(store.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                    if store.isLoading {
                        HStack {
                            ProgressView()
                            Text("Thinking on device…")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .onChange(of: store.messages.count) { _, _ in
                if let last = store.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }

    private var composer: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("Message LocalMind…", text: $store.input, axis: .vertical)
                .lineLimit(1...5)
                .textFieldStyle(.roundedBorder)
                .disabled(!store.llm.isLoaded || store.isLoading)
            Button {
                Task { await store.send() }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
            }
            .disabled(store.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                      || !store.llm.isLoaded || store.isLoading)
        }
        .padding()
        .background(.bar)
    }
}

private struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .assistant { bubble }
            else {
                Spacer(minLength: 42)
                bubble
            }
            if message.role == .assistant { Spacer(minLength: 42) }
        }
    }

    private var bubble: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(message.role == .user ? "You" : "LocalMind")
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
            Text(message.text)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(message.role == .user ? Color.accentColor.opacity(0.16) : Color.secondary.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
