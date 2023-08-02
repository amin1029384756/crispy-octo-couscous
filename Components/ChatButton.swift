import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

protocol ChatButtonDelegate: AnyObject {
    func openChatList()
}

class ChatButton: UIView {
    weak var delegate: ChatButtonDelegate?
    let db = Firestore.firestore()

    lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.snp.makeConstraints {
            $0.width.equalTo(32)
            $0.height.equalTo(32)
        }
        imageView.contentMode = .center
        return imageView
    }()

    lazy var titleLabel = Label(style: .smallNormal, text: "CHAT", color: Color.main, lines: 1)

    lazy var badgeLabel = Label(style: .smallBold, text: "0", color: .white, lines: 1)

    lazy var button = UIButton(type: .custom)

    init(delegate: ChatButtonDelegate?) {
        self.delegate = delegate

        super.init(frame: .zero)

        iconView.image = ImageAsset.iconChat.image
        addWithConstraints(view: iconView) {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }

        badgeLabel.isHidden = true
        badgeLabel.backgroundColor = .red
        badgeLabel.layer.cornerRadius = 7
        badgeLabel.layer.masksToBounds = true
        badgeLabel.textAlignment = .center
        addWithConstraints(view: badgeLabel) {
            $0.trailing.equalTo(iconView.snp.trailing)
            $0.top.equalTo(iconView.snp.top)
            $0.width.equalTo(14)
            $0.height.equalTo(14)
        }

        titleLabel.textAlignment = .center
        addWithConstraints(view: titleLabel) {
            $0.fillHorizontally()
            $0.bottom.equalToSuperview()
            $0.below(iconView, padding: -4)
            $0.height.equalTo(20)
        }

        button.setTitle(" ", for: .normal)
        button.addTarget(self, action: #selector(openChatList), for: .touchUpInside)
        addWithConstraints(view: button) {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(40)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        updateBadge()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateBadge() {
        Task {
            let badge = await getBadge()
            await MainActor.run {
                set(badge: badge)
            }
        }
    }

    private func getBadge() async -> Int {
        guard let userId = Auth.auth().currentUser?.uid else {
            return 0
        }

        let querySnapshot = try? await db.collection("chats")
            .whereField(User.isHost ? "hostId" : "guestId", isEqualTo: userId)
            .getDocuments()

        let documents = querySnapshot?.documents ?? []
        var badgeNum = 0
        for document in documents {
            badgeNum += await checkUnreadMessages(chatId: document.documentID)
        }
        return badgeNum
    }

    private func checkUnreadMessages(chatId: String) async -> Int {
        guard let userId = Auth.auth().currentUser?.uid else {
            return 0
        }

        return (try? await db.collection("chats")
            .document(chatId)
            .collection("messages")
            .whereField("senderId", isNotEqualTo: userId)
            .whereField("seen", isEqualTo: false)
            .getDocuments())?
            .count ?? 0
    }

    func set(badge: Int) {
        if badge > 0, badge < 10 {
            badgeLabel.isHidden = false
            badgeLabel.text = "\(badge)"
        } else if badge >= 10 {
            badgeLabel.isHidden = false
            badgeLabel.text = "9+"
        } else {
            badgeLabel.isHidden = true
        }
    }

    @objc func openChatList() {
        delegate?.openChatList()
    }
}
