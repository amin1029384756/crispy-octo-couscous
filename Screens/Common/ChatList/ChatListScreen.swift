import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatListScreen: Screen<ChatListLayout> {
    lazy var adapterChats = ChatListAdapter(delegate: self)
    lazy var adapterSuggestions = ChatListSuggestionsAdapter(delegate: self)
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self
        layout.list.delegate = adapterChats
        layout.list.dataSource = adapterChats
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loader.show()
        loadChats()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    override func refresh() {
        super.refresh()

        loadChats()
    }

    private func loadChats() {
        guard let uid = Auth.auth().currentUser?.uid else {
            loader.dismiss()
            show(chats: [], suggestions: [])
            return
        }

        Task {
            do {
                let chats = try await getChatsAsync(userId: uid)
                var chatsWithMessages = [(ChatInfo, ChatMessage)]()
                for chat in chats {
                    if let message = try? await getLastMessageAsync(chatInfo: chat) {
                        chatsWithMessages.append((chat, message))
                    }
                }
                let suggestions = await getSuggestions()
                await MainActor.run {
                    loader.dismiss()
                    layout.refreshControl.endRefreshing()
                    show(chats: chatsWithMessages, suggestions: suggestions)
                }
            } catch {
                await MainActor.run {
                    loader.dismiss()
                    layout.refreshControl.endRefreshing()
                    show(error: error.localizedDescription)
                }
            }
        }
    }

    private func getChatsAsync(userId: String) async throws -> [ChatInfo] {
        let querySnapshot = try await db.collection("chats")
            .whereField("hostId", isEqualTo: userId)
            .getDocuments()

        let documents = querySnapshot.documents
        var chats = documents.compactMap { document -> ChatInfo? in
            document.toChatInfo()
        }.filter {
            !$0.isBlocked
        }

        let querySnapshot2 = try await db.collection("chats")
            .whereField("guestId", isEqualTo: userId)
            .getDocuments()

        let documents2 = querySnapshot2.documents
        let chats2 = documents2.compactMap { document -> ChatInfo? in
            document.toChatInfo()
        }

        chats.append(contentsOf: chats2)

        return chats
    }

    private func getSuggestions() async -> [KtorGetChatSuggestedGuestsResponse] {
        do {
            return try await KtorGetChatSuggestedGuestsRequest()
                .performDataRequest()
        } catch {
            return []
        }
    }

    private func getLastMessageAsync(chatInfo: ChatInfo) async throws -> ChatMessage {
        let querySnapshot = try await db.collection("chats")
            .document(chatInfo.chatId)
            .collection("messages")
            .order(by: "date", descending: true)
            .limit(to: 1)
            .getDocuments()

        guard let document = querySnapshot.documents.first else {
            throw ApiError.missingResponse
        }

        let data = document.data()

        guard let text = data["text"] as? String,
              let date = data["date"] as? Timestamp,
              let senderId = data["senderId"] as? String
        else {
            throw ApiError.missingResponse
        }

        let isHost: Bool
        let displayName: String
        if senderId == Auth.auth().currentUser?.uid {
            isHost = User.isHost
        } else {
            isHost = !User.isHost
        }
        if isHost {
            displayName = chatInfo.hostName
        } else {
            displayName = chatInfo.guestName
        }

        return ChatMessage(
            _sender: ChatSender(
                senderId: senderId,
                displayName: displayName,
                isHost: isHost
            ),
            messageId: document.documentID,
            sentDate: date.dateValue(),
            kind: .text(text),
            seenDate: (data["seenDate"] as? Timestamp)?.dateValue(),
            seen: (data["seen"] as? Bool) ?? false
        )
    }

    private func show(chats: [(ChatInfo, ChatMessage)], suggestions: [KtorGetChatSuggestedGuestsResponse]) {
        adapterChats.chats = chats
        adapterSuggestions.suggestions = suggestions

        if suggestions.isEmpty {
            // Hide tabs
            layout.chatTabsSegments.isHidden = true
            layout.listTopConstraint.constraint.update(offset: 0)
        } else {
            // Show tabs
            layout.chatTabsSegments.isHidden = false
            layout.listTopConstraint.constraint.update(offset: -56)
        }

        layout.layoutIfNeeded()
        layout.list.reloadData()
    }

    func tabChanged(tabIdx: Int) {
        if tabIdx == 0 {
            layout.list.delegate = adapterChats
            layout.list.dataSource = adapterChats
        } else {
            layout.list.delegate = adapterSuggestions
            layout.list.dataSource = adapterSuggestions
        }
        layout.list.reloadData()
    }
}

extension ChatListScreen: ChatListAdapterDelegate {
    func chatSelected(chatInfo: ChatInfo) {
        let chatScreen = ChatScreen()
        chatScreen.chatInfo = chatInfo
        navigator.navigationController.pushViewController(chatScreen, animated: true)
    }
}

extension ChatListScreen: ChatListSuggestionsAdapterDelegate {
    func suggestionSelected(suggestion: KtorGetChatSuggestedGuestsResponse) {
        guard let hostUID = Auth.auth().currentUser?.uid else {
            return
        }
        loader.showIfNot()
        db.collection("chats")
            .whereField("guestId", isEqualTo: suggestion.uid)
            .whereField("hostId", isEqualTo: hostUID)
            .getDocuments { [weak self] (snapshot: QuerySnapshot?, error: Error?) in
                if let snap = snapshot?.documents.first,
                   let chatInfo = snap.toChatInfo(){
                    let chatScreen = ChatScreen()
                    chatScreen.chatInfo = chatInfo
                    self?.navigator.navigationController.pushViewController(chatScreen, animated: true)
                } else {
                    self?.createNewChat(suggestion: suggestion, hostUID: hostUID)
                }
            }
    }

    private func createNewChat(
        suggestion: KtorGetChatSuggestedGuestsResponse,
        hostUID: String
    ) {
        let doc = db.collection("chats")
            .document()
        doc.setData([
            "guestId": suggestion.uid,
            "hostId": hostUID,
            "guestName": suggestion.name,
            "hostName": hostDisplayName,
            "messagesAvailable": StaticConfig.messagesAvailableInChat,
            "messagesUsed": 0,
            "messagesOnDemandAvailable": 0,
            "messagesOnDemandUsed": 0
        ], completion: { [weak self] error in
            if let error = error {
                self?.loader.dismiss()
                self?.show(error: error.localizedDescription)
            } else {
                DispatchQueue.main.async { [weak self] in
                    let chatInfo = ChatInfo(
                        chatId: doc.documentID,
                        guestId: suggestion.uid,
                        hostId: hostUID,
                        guestName: suggestion.name,
                        hostName: self?.hostDisplayName ?? "",
                        isBlocked: false)
                    let chatScreen = ChatScreen()
                    chatScreen.chatInfo = chatInfo
                    self?.navigator.navigationController.pushViewController(chatScreen, animated: true)
                }
            }
        })
    }

    private func startChat(chatInfo: ChatInfo) {
        let chatScreen = ChatScreen()
        chatScreen.chatInfo = chatInfo
        navigator.navigationController.pushViewController(chatScreen, animated: true)
    }

    private var hostDisplayName: String {
        if let nickname = User.active?.profile.nickname?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !nickname.isEmpty {
            return nickname
        } else if let firstName = User.active?.profile.firstName
            .trimmingCharacters(in: .whitespacesAndNewlines),
                  !firstName.isEmpty {
            return firstName
        } else {
            return Auth.auth().currentUser?.displayName ?? ""
        }
    }
}
