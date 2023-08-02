import MessageKit

struct ChatSender: MessageKit.SenderType {
    let senderId: String
    let displayName: String
    let isHost: Bool
}
