import SwiftUI

@main
struct LocalMindAIApp: App {
    @StateObject private var store = ChatStore()

    var body: some Scene {
        WindowGroup {
            ChatView()
                .environmentObject(store)
                .preferredColorScheme(store.darkMode ? .dark : .light)
        }
    }
}
