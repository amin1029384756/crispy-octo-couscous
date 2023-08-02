import SnapKit
import UIKit

enum TopBarMode {
    case host
    case guest
}

protocol TopBarDelegate: AnyObject {
    func profileButtonClicked()
    func rightButtonClicked()
}

class TopBar: UIView {
    private let mode: TopBarMode
    private weak var delegate: TopBarDelegate?

    lazy var profileButton = ImageButton(asset: .buttonProfile, delegate: self)

    lazy var guestBadgeLabel = Label(style: .experienceTitle, text: "", color: Color.main, lines: 1)

    lazy var hostBadgeLabel = Label(style: .experienceTitle, text: "", color: .white, lines: 1)

    lazy var rightButton = ImageButton(asset: .iconWallet, delegate: self)

    lazy var separator = Image(asset: .navbarShade)

    lazy var titleLabel = Label(style: .topBarTitle, text: "", color: Color.titleText, lines: 1)

    init(mode: TopBarMode, title: String?, customTopView: UIView?, delegate: TopBarDelegate) {
        self.delegate = delegate
        self.mode = mode

        super.init(frame: .zero)

        backgroundColor = .white

        addWithConstraints(view: separator) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(snp.bottom)
        }

        addWithConstraints(view: profileButton) {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(12)
            $0.width.equalTo(32)
            $0.height.equalTo(32)
        }

        switch mode {
        case .host:
            rightButton.setImage(asset: .iconDocument)
            addWithConstraints(view: rightButton) {
                $0.trailing.equalToSuperview().offset(-20)
                $0.top.equalToSuperview().offset(12)
                $0.width.equalTo(30)
                $0.height.equalTo(27)
            }

            hostBadgeLabel.textAlignment = .center
            hostBadgeLabel.backgroundColor = Color.main
            hostBadgeLabel.layer.cornerRadius = 12
            hostBadgeLabel.layer.borderWidth = 2
            hostBadgeLabel.layer.borderColor = Color.mainDark.cgColor
            hostBadgeLabel.layer.masksToBounds = true
            addWithConstraints(view: hostBadgeLabel) {
                $0.trailing.equalToSuperview().offset(-6)
                $0.top.equalToSuperview().offset(6)
                $0.width.equalTo(24)
                $0.height.equalTo(24)
            }

            setHostBadge(num: TopBar.cachedHostBadge)

        case .guest:
            guestBadgeLabel.textAlignment = .center
            addWithConstraints(view: guestBadgeLabel) {
                $0.trailing.equalToSuperview().offset(-23)
                $0.top.equalToSuperview().offset(17)
                $0.width.equalTo(31)
                $0.height.equalTo(34)
            }

            rightButton.setImage(asset: .iconWallet)
            addWithConstraints(view: rightButton) {
                $0.trailing.equalToSuperview().offset(-20)
                $0.top.equalToSuperview().offset(12)
                $0.width.equalTo(31)
                $0.height.equalTo(34)
            }

            setGuestBadge(num: TopBar.cachedGuestBadge)
        }

        if let title = title {
            addWithConstraints(view: titleLabel) {
                $0.leading.equalTo(profileButton.snp.trailing).offset(8)
                $0.trailing.equalTo(rightButton.snp.leading).offset(-8)
                $0.centerY.equalTo(profileButton.snp.centerY)
            }
            titleLabel.text = title.uppercased()
            titleLabel.textAlignment = .center
        } else if let customTopView = customTopView {
            addWithConstraints(view: customTopView) {
                $0.leading.equalTo(profileButton.snp.trailing).offset(8)
                $0.trailing.equalTo(rightButton.snp.leading).offset(-8)
                $0.centerY.equalTo(profileButton.snp.centerY)
            }
        }

        snp.makeConstraints {
            $0.height.equalTo(70)
        }

        refresh()
    }

    func refresh() {
        switch mode {
        case .guest:
            ReservationIndexRequest()
                .performRequestWithDelegate { [weak self] response, _ in
                    let reservations = response?.result.data?.count ?? 0
                    TopBar.cachedGuestBadge = reservations
                    DispatchQueue.main.async { [weak self] in
                        self?.setGuestBadge(num: reservations)
                    }
                }

        case .host:
            EarningIndexRequest()
                .performRequestWithDelegate { [weak self] response, _ in
                    let earnings = response?.result.data?.count ?? 0
                    TopBar.cachedHostBadge = earnings
                    DispatchQueue.main.async { [weak self] in
                        self?.setHostBadge(num: earnings)
                    }
                }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setGuestBadge(num: Int) {
        if num <= 0 {
            guestBadgeLabel.text = ""
            rightButton.setImage(asset: .iconWallet)
        } else {
            guestBadgeLabel.text = "\(num)"
            rightButton.setImage(asset: .iconWalletWithMoney)
        }
    }

    func setHostBadge(num: Int) {
        if num <= 0 {
            hostBadgeLabel.isHidden = true
        } else {
            hostBadgeLabel.isHidden = false
            if num < 10 {
                hostBadgeLabel.text = "\(num)"
            } else {
                hostBadgeLabel.text = "9+"
            }
        }
    }

    static var cachedGuestBadge: Int {
        get {
            if let uid = User.active?.uid {
                return UserDefaults.standard.integer(forKey: "cachedGuestBadge.\(uid)")
            } else {
                return 0
            }
        }
        set {
            if let uid = User.active?.uid {
                return UserDefaults.standard.set(newValue, forKey: "cachedGuestBadge.\(uid)")
            }
        }
    }

    static var cachedHostBadge: Int {
        get {
            if let uid = User.active?.uid {
                return UserDefaults.standard.integer(forKey: "cachedHostBadge.\(uid)")
            } else {
                return 0
            }
        }
        set {
            if let uid = User.active?.uid {
                return UserDefaults.standard.set(newValue, forKey: "cachedHostBadge.\(uid)")
            }
        }
    }
}

extension TopBar: ImageButtonDelegate {
    func imageButtonClicked(imageButton: ImageButton) {
        switch imageButton {
        case profileButton:
            delegate?.profileButtonClicked()

        case rightButton:
            delegate?.rightButtonClicked()

        default:
            break
        }
    }
}
