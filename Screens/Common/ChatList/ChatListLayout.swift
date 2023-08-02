import UIKit
import SnapKit

class ChatListLayout: Layout {
    lazy var topBar = TopBar(mode: User.active?.role == UserRole.host ? .host : .guest, title: "CHAT", customTopView: nil, delegate: self)

    lazy var chatTabsSegments: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: [
            "ACTIVE CHATS",
            "SUGGESTED GUESTS"
        ])

        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UISegmentedControl.appearance().setTitleTextAttributes(titleTextAttributes, for: .selected)
        segmentedControl.selectedSegmentTintColor = Color.main
        segmentedControl.tintColor = Color.main
        segmentedControl.addTarget(self, action: #selector(self.tabChanged), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0

        return segmentedControl
    }()

    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = Color.main
        control.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        return control
    }()

    lazy var list = UITableView()

    lazy var bottomBackButton = ShadyBackButton(delegate: self)

    var listTopConstraint: ConstraintMakerEditable!

    weak var screen: ChatListScreen?

    override func createLayout() {
        super.createLayout()

        chatTabsSegments.isHidden = true
        addWithConstraints(view: chatTabsSegments) {
            $0.fillHorizontally(padding: 16)
        }

        addWithConstraints(view: list) {
            $0.fillHorizontally()
            $0.bottom.equalToSuperview()
        }
        list.backgroundColor = Color.bright
        list.register(ChatSuggestionItemCell.self, forCellReuseIdentifier: ChatSuggestionItemCell.cellId)
        list.register(ChatItemCell.self, forCellReuseIdentifier: ChatItemCell.cellId)
        list.separatorStyle = .none
        list.allowsSelection = true
        list.addSubview(refreshControl)

        addWithConstraints(view: topBar) {
            $0.top.equalTo(layoutMarginsGuide.snp.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            listTopConstraint = $0.bottom.equalTo(list.snp.top)
            $0.bottom.equalTo(chatTabsSegments.snp.top).offset(-12)
        }

        addWithConstraints(view: bottomBackButton) {
            $0.leading.equalToSuperview().offset(30)
            $0.bottom.equalToSuperview().offset(28)
        }
    }

    @objc func refresh() {
        screen?.refresh()
    }

    @objc func tabChanged() {
        screen?.tabChanged(tabIdx: chatTabsSegments.selectedSegmentIndex)
    }
}

extension ChatListLayout: TopBarDelegate {
    func profileButtonClicked() {
        screen?.openProfile()
    }

    func rightButtonClicked() {
        if User.active?.role == UserRole.host {
            screen?.openEarnings()
        } else {
            screen?.openWallet()
        }
    }
}

extension ChatListLayout: ShadyBackButtonDelegate {
    func backTapped() {
        screen?.goBack()
    }
}
