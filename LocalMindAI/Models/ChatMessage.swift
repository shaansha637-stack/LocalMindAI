import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    enum Role: String, Codable {
        case user
        case assistant
    }

    let id: UUID
    let role: Role
    let text: String
    let createdAt: Date

    init(role: Role, text: String, createdAt: Date = .now) {
        self.id = UUID()
        self.role = role
        self.text = text
        self.createdAt = createdAt
    }
}
