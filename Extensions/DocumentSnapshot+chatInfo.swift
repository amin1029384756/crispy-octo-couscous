import FirebaseFirestore

extension DocumentSnapshot {
    func toChatInfo() -> ChatInfo? {
        guard let data = self.data() else {
            return nil
        }
        let guestId = (data["guestId"] as? String) ?? ""
        let hostId = (data["hostId"] as? String) ?? ""
        let guestName = (data["guestName"] as? String) ?? ""
        let hostName = (data["hostName"] as? String) ?? ""
        let isBlocked = (data["isBlocked"] as? Bool) ?? false
        let chatInfo = ChatInfo(
            chatId: documentID,
            guestId: guestId,
            hostId: hostId,
            guestName: guestName,
            hostName: hostName,
            isBlocked: isBlocked
        )
        return chatInfo
    }
}
