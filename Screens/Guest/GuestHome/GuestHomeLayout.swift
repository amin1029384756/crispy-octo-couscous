import UIKit

class GuestHomeLayout: Layout {
    lazy var topBar = TopBar(mode: .guest, title: nil, customTopView: chatButton, delegate: self)

    lazy var chatButton = ChatButton(delegate: self)

    lazy var topSelectorView: UIView = {
        let view = UIView()

        view.addWithConstraints(view: swiTalkListen) {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-5)
        }

        talkMore.isUserInteractionEnabled = true
        talkMore.addGestureRecognizer(talkMoreTapDetector)
        view.addWithConstraints(view: talkMore) {
            $0.trailing.equalTo(swiTalkListen.snp.leading).offset(-4)
            $0.top.equalToSuperview().offset(3)
            $0.bottom.equalToSuperview()
        }

        listenMore.isUserInteractionEnabled = true
        listenMore.addGestureRecognizer(listenMoreTapDetector)
        view.addWithConstraints(view: listenMore) {
            $0.leading.equalTo(swiTalkListen.snp.trailing).offset(4)
            $0.top.equalToSuperview().offset(3)
            $0.bottom.equalToSuperview()
        }

        return view
    }()

    lazy var swiTalkListen: UISwitch = {
        let swi = UISwitch()
        swi.isOn = UserDefaults.standard.bool(forKey: "com.wythyou.option.preferListen")
        swi.onTintColor = .white
        swi.tintColor = .white
        swi.thumbTintColor = Color.mainDark
        swi.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        swi.layer.borderColor = Color.darkGray.cgColor
        swi.layer.borderWidth = 1.0
        swi.layer.cornerRadius = 15
        return swi
    }()

    lazy var talkMoreTapDetector = UITapGestureRecognizer(target: self, action: #selector(talkMoreSelected))
    lazy var talkMore = TopSelectorBlock(title: "TALK MORE", icon: .iconTalkMore)

    lazy var listenMoreTapDetector = UITapGestureRecognizer(target: self, action: #selector(listenMoreSelected))
    lazy var listenMore = TopSelectorBlock(title: "LISTEN MORE", icon: .iconListenMore)

    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = Color.main
        control.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        return control
    }()

    lazy var coinsBox = CoinsBox(balance: User.active?.coins ?? 0, delegate: self)

    lazy var list = UITableView()

    weak var screen: GuestHomeScreen?

    override func createLayout() {
        addWithConstraints(view: list) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        list.backgroundColor = Color.bright
        list.register(EventGroupCell.self, forCellReuseIdentifier: EventGroupCell.cellId)
        list.register(EventCell.self, forCellReuseIdentifier: EventCell.cellId)
        list.separatorStyle = .none
        list.allowsSelection = true

        addWithConstraints(view: topSelectorView) {
            $0.height.equalTo(70)
            $0.fillHorizontally()
            $0.bottom.equalTo(list.snp.top)
        }

        addWithConstraints(view: coinsBox) {
            $0.centerY.equalTo(topSelectorView.snp.centerY)
            $0.trailing.equalToSuperview().offset(12)
        }

        addWithConstraints(view: topBar) {
            $0.top.equalTo(layoutMarginsGuide.snp.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(topSelectorView.snp.top)
        }

        list.addSubview(refreshControl)

        showFilter()
    }

    @objc func refresh() {
        screen?.refresh()
    }

    @objc func filterChanged() {
        UserDefaults.standard.set(swiTalkListen.isOn, forKey: "com.wythyou.option.preferListen")
        screen?.filterUpdated(preferListen: swiTalkListen.isOn)
        showFilter()
    }

    func showFilter() {
        talkMore.setSelected(!swiTalkListen.isOn)
        listenMore.setSelected(swiTalkListen.isOn)
    }

    @objc func talkMoreSelected() {
        swiTalkListen.isOn = false
        filterChanged()
    }

    @objc func listenMoreSelected() {
        swiTalkListen.isOn = true
        filterChanged()
    }
}

extension GuestHomeLayout: TopBarDelegate {
    func profileButtonClicked() {
        screen?.openProfile()
    }

    func rightButtonClicked() {
        screen?.openWallet()
    }
}

extension GuestHomeLayout: ChatButtonDelegate {
    func openChatList() {
        screen?.openChatList()
    }
}

extension GuestHomeLayout: CoinsBoxDelegate {
    func onCoinBoxTapped() {
        screen?.openCoins()
    }
}
