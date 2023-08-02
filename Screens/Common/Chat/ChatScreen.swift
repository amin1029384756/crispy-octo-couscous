import UIKit
import MessageKit
import FirebaseAuth
import FirebaseFirestore
import InputBarAccessoryView
import Toast_Swift

class ChatScreen: MessagesViewController {
    var chatInfo: ChatInfo!
    let db = Firestore.firestore()

    var messages = [ChatMessage]()
    var listener: ListenerRegistration!
    var chatRef: DocumentReference!
    var messagesRef: CollectionReference!
    var messagesLoaded = false
    var buyController: ChatPurchaseController?

    var messageLimit = 0
    var messagesUsed = 0
    var messageRefreshTime = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = isUserHost ? chatInfo.guestName : chatInfo.hostName

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        // "ZAXYeXWH7x8zGSXF4IKf"
        chatRef = db.collection("chats").document(chatInfo.chatId)
        messagesRef = chatRef.collection("messages")

        view.addWithConstraints(view: coinsBox) {
            $0.top.equalTo(view.layoutMarginsGuide.snp.top).offset(12)
            $0.trailing.equalToSuperview().offset(12)
        }

        configureMessageInputBar()
        showMessagesLeftButton()

        Task {
            await refreshLimits()
        }
    }

    func refreshLimits() async {
        if !isUserHost {
            messageLimit = User.active?.messageLimit ?? 0
            messagesUsed = User.active?.messagesUsed ?? 0
            messageRefreshTime = Date()
            await MainActor.run {
                showMessagesLeftButton()
            }
        }

        if let messagesCounter = try? await KtorGetProfileMessagesRequest(uid: chatInfo.guestId).performDataRequest() {
            messageLimit = messagesCounter.messageLimit
            messagesUsed = messagesCounter.messagesUsed
            messageRefreshTime = Date()
        }
        await MainActor.run {
            showMessagesLeftButton()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIApplication.shared.applicationIconBadgeNumber = 0
        coinsBox.update(balance: User.active?.coins ?? 0)

        showWelcomePopupIfNotYet()
    }

    func configureMessageInputBar() {
        messageInputBar.inputTextView.placeholder = "Write a message..."
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = Color.main
        messageInputBar.sendButton.setTitleColor(Color.main, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            Color.main.withAlphaComponent(0.3),
            for: .highlighted
        )
    }

    private func listenNewMessages() {
        listener = messagesRef
            .addSnapshotListener { [weak self] (querySnapshot: QuerySnapshot?, error: Error?) in
                guard let documents = querySnapshot?.documentChanges,
                      !documents.isEmpty,
                      let self = self
                else {
                    return
                }

                let newMessages = documents.compactMap { doc in
                    self.createChatMessage(
                        documentID: doc.document.documentID,
                        data: doc.document.data()
                    )
                }

                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    for newMessage in newMessages {
                        if newMessage.sender.senderId != Auth.auth().currentUser?.uid,
                            !self.messageCounted.contains(newMessage.messageId) {
                            self.messagesUsed += 1
                            self.messageCounted.insert(newMessage.messageId)
                        }
                    }
                    self.showMessagesLeftButton()
                    self.insertMessages(messages: newMessages, forceScrollDown: self.messagesLoaded == false)
                }
            }
    }

    var messageCounted = Set<String>()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.isNavigationBarHidden = false
        listenNewMessages()
    }

    private func createChatMessage(
        documentID: String,
        data: [String: Any]
    ) -> ChatMessage? {
        guard let text = data["text"] as? String,
              let date = data["date"] as? Timestamp,
              let senderId = data["senderId"] as? String
        else {
            return nil
        }

        let isHost: Bool
        let displayName: String
        if senderId == Auth.auth().currentUser?.uid {
            isHost = isUserHost
        } else {
            isHost = !isUserHost
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
            messageId: documentID,
            sentDate: date.dateValue(),
            kind: .text(text),
            seenDate: (data["seenDate"] as? Timestamp)?.dateValue(),
            seen: (data["seen"] as? Bool) ?? false
        )
    }

    func refresh() {
        Task {
            do {
                let snapshot = try await chatRef.getDocument()
                if let chatInfo = snapshot.toChatInfo() {
                    self.chatInfo = chatInfo
                }
                await self.refreshLimits()
            } catch {
                // No action required
            }
        }
    }

    lazy var topButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.tintColor = Color.main
        button.target = self
        button.action = #selector(buyMessages)
        return button
    }()

    lazy var reportButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.tintColor = .red
        button.target = self
        button.action = #selector(reportChat)
        button.image = UIImage(systemName: "flag.fill")
        return button
    }()

    lazy var coinsBox = CoinsBox(balance: User.active?.coins ?? 0, delegate: self)

    @objc func buyMessages() {
        if isUserHost {
            let alert = UIAlertController(title: "Message limit", message: "This numbers show amount of messages this guest used and amount of messages available. Only guest can buy more messages.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
        } else {
            buyController = ChatPurchaseController(viewController: self, isPopup: true)
        }
    }

    @objc func reportChat() {
        report(messageId: nil)
    }

    private func showWelcomePopupIfNotYet() {
        if isUserHost {
            return
        }

        if let nickname = User.active?.profile.nickname,
           !nickname.isEmpty {
            if UserDefaults.standard.bool(forKey: "wythyou.welcome.chat.shown") {
                return
            }

            let popup = WelcomePopup(delegate: self)
            popup.openSecondScreen()
            view.addWithConstraints(view: popup) {
                $0.edges.equalToSuperview()
            }
        }
    }

    var topButtonAdded = false

    func showMessagesLeftButton() {
        let buttonTitle: String
        if messagesUsed == 0, messageLimit == 0 {
            buttonTitle = "..."
        } else {
            buttonTitle = "\(messagesUsed)/\(messageLimit)"
        }

        if !topButtonAdded {
            navigationItem.rightBarButtonItems = [topButton, reportButton]
        }

        topButton.title = buttonTitle
    }

    private func insertMessages(messages: [ChatMessage], forceScrollDown: Bool = false) {
        messagesLoaded = true

        var batch: WriteBatch?
        for message in messages {
            if self.messages.first(where: { $0.messageId == message.messageId }) == nil {
                if !message.seen,
                   message.sender.senderId != Auth.auth().currentUser?.uid {
                    // Mark as seen
                    if batch == nil {
                        batch = db.batch()
                    }
                    batch?.updateData([
                        "seenDate": Date(),
                        "seen": true
                    ], forDocument: messagesRef.document(message.messageId))
                }
                self.messages.append(message)
            }
        }
        batch?.commit()

        self.messages.sort { (v1: ChatMessage, v2: ChatMessage) in
            v1.sentDate < v2.sentDate
        }

        messagesCollectionView.reloadData()

        if forceScrollDown || isLastSectionVisible {
            messagesCollectionView.scrollToLastItem(animated: true)
        }
    }

    var isLastSectionVisible: Bool {
        guard !messages.isEmpty else { return false }

        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)

        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        listener.remove()

        navigationController?.isNavigationBarHidden = true
    }

    func report(messageId: String?) {
        let reportBox = ChatReportBox(chatId: chatInfo.chatId, messageId: messageId, delegate: self)
        view.addWithConstraints(view: reportBox) {
            $0.edges.equalToSuperview()
        }
    }
}

extension ChatScreen: MessagesDataSource {
    var isUserHost: Bool {
        chatInfo.hostId == Auth.auth().currentUser?.uid
    }

    var userDisplayName: String {
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

    var currentSender: MessageKit.SenderType {
        ChatSender(
            senderId: Auth.auth().currentUser?.uid ?? "",
            displayName: userDisplayName,
            isHost: isUserHost
        )
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        messages.count
    }
}

extension ChatScreen: MessagesDisplayDelegate, MessagesLayoutDelegate {
    public func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let nameParts = message.sender.displayName.components(separatedBy: " ")
        var initials = ""
        for namePart in nameParts where !namePart.isEmpty {
            if let firstLetter = namePart.first {
                initials.append(firstLetter)
            }
        }
        avatarView.initials = initials
    }
}

extension ChatScreen: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard let text = inputBar.inputTextView.text,
              !text.isEmpty
        else {
            return
        }

        if messagesUsed >= messageLimit {
//            if isUserHost {
//                // Host can't send messages on demand
//                let warningMessage = "You can't send more messages to \(chatInfo.guestName). They need to book an experience to continue conversation."
//                let alert = UIAlertController(title: "No messages left", message: warningMessage, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//                present(alert, animated: true)
//                return
//            } else
            if !isUserHost {
                buyMessages()
                return
            }
        }

        view.endEditing(true)
        inputBar.inputTextView.text = ""
        inputBar.invalidatePlugins()
        inputBar.sendButton.startAnimating()

        let newDoc = messagesRef.document()
        let chatId = chatInfo.chatId

        newDoc.setData([
            "text": text,
            "date": Date(),
            "senderId": Auth.auth().currentUser?.uid ?? "",
            "seen": false
        ]) { [weak self] error in
            if error == nil, let self = self {
                self.messagesUsed += 1
                if !self.isUserHost {
                    User.active?.messagesUsed = self.messagesUsed
                }
            }

            inputBar.sendButton.stopAnimating()
            inputBar.inputTextView.placeholder = "Write a message..."

            self?.showMessagesLeftButton()

            Task {
                do {
                    try await KtorChatsMessageRequest(
                        chatId: chatId,
                        messageId: newDoc.documentID
                    ).performRequest()

                    if let isUserHost = self?.isUserHost {
                        if isUserHost {
                            User.active?.coins += 1
                        } else {
                            User.active?.coins += 3
                        }
                        self?.coinsBox.update(balance: User.active?.coins ?? 0)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        // No action required
    }

    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        // No action required
    }

    func inputBar(_ inputBar: InputBarAccessoryView, didSwipeTextViewWith gesture: UISwipeGestureRecognizer) {
        // No action required
    }
}

extension ChatScreen: MessageCellDelegate {
    public func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              let messagesDataSource = messagesCollectionView.messagesDataSource
        else { return }

        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)

        DispatchQueue.main.async { [weak self] in
            var messageText: String?
            if case let .text(text) = message.kind {
                messageText = text
            }

            let alert = UIAlertController(
                title: "Message from \(message.sender.displayName)",
                message: messageText,
                preferredStyle: .actionSheet)
            if let messageText = messageText,
               !messageText.isEmpty {
                alert.addAction(UIAlertAction(
                    title: "Copy Message",
                    style: .default) { [weak self] _ in
                    UIPasteboard.general.string = messageText
                    self?.view.makeToast(
                        "Message was copied",
                        duration: 3.0,
                        position: .bottom,
                        title: "Success",
                        image: nil,
                        style: ToastStyle(),
                        completion: nil
                    )
                })
            }
            if message.sender.senderId != Auth.auth().currentUser?.uid {
                alert.addAction(UIAlertAction(
                    title: "Report / Block",
                    style: .destructive) { [weak self] _ in
                    self?.report(messageId: message.messageId)
                })
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self?.present(alert, animated: true)
        }
    }
}

extension ChatScreen: PWelcomePopupDelegate {
    func closeWelcomePopup(popup: WelcomePopup) {
        popup.removeFromSuperview()
        UserDefaults.standard.set(true, forKey: "wythyou.welcome.chat.shown")
    }

    func openProfileScreen() {
        let profileScreen = ProfileScreen()
        navigationController?.pushViewController(profileScreen, animated: true)
    }
}

extension ChatScreen: PChatReportBoxDelegate {
    func sendReport(chatId: String, messageId: String?, blockChat: Bool, text: String) {
        let loader = Loader(rootView: view)
        loader.show()
        Task {
            do {
                if !text.isEmpty {
                    try await KtorReportChatRequest(
                        chatId: chatId,
                        messageId: messageId,
                        text: text)
                        .performRequest()
                }
                if blockChat {
                    let blockedBy = Auth.auth().currentUser?.uid ?? ""
                    try await chatRef.updateData([
                        "isBlocked": true,
                        "blockedBy": blockedBy
                    ])
                }

                await MainActor.run {
                    loader.dismiss()
                    _ = navigationController?.popViewController(animated: true)
                }
            } catch {
                await MainActor.run {
                    loader.dismiss()
                    show(error: error.localizedDescription)
                }
            }
        }
    }
}

extension ChatScreen: CoinsBoxDelegate {
    func onCoinBoxTapped() {
        let guestCoinsScreen = GuestCoinsScreen()
        navigationController?.pushViewController(guestCoinsScreen, animated: true)
    }
}
