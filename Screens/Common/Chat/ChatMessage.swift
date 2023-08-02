import MessageKit

struct ChatMessage: MessageType {
    var sender: MessageKit.SenderType { _sender }

    let _sender: ChatSender
    let messageId: String
    let sentDate: Date
    let kind: MessageKind
    let seenDate: Date?
    let seen: Bool
}
