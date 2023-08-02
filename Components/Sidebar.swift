import UIKit
import SnapKit
import GoogleSignIn

class Sidebar<L: Layout>: UIView {
    weak var screen: Screen<L>?

    var appeared = false

    lazy var backgroundButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(" ", for: .normal)
        button.addTarget(self, action: #selector(disappear), for: .touchUpInside)
        return button
    }()

    lazy var barContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Color.main.withAlphaComponent(0.95)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true

        view.addWithConstraints(view: profilePictureView) {
            $0.centerX.equalToSuperview().offset(8)
            $0.top.equalToSuperview().offset(48)
        }

        lblName.textAlignment = .center
        view.addWithConstraints(view: lblName) {
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalTo(profilePictureView.snp.bottom).offset(12)
        }

        lblPhone.textAlignment = .center
        view.addWithConstraints(view: lblPhone) {
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalTo(lblName.snp.bottom)
        }

        view.addWithConstraints(view: line1) {
            $0.leading.equalToSuperview().offset(50)
            $0.trailing.equalToSuperview().offset(-28)
            $0.top.equalTo(lblPhone.snp.bottom).offset(20)
            $0.height.equalTo(1)
        }

        view.addWithConstraints(view: swiHostGuest) {
            $0.centerX.equalToSuperview().offset(8)
            $0.top.equalTo(line1.snp.bottom).offset(10)
        }

        view.addWithConstraints(view: lblHost) {
            $0.centerY.equalTo(swiHostGuest.snp.centerY)
            $0.trailing.equalTo(swiHostGuest.snp.leading).offset(-14)
        }

        view.addWithConstraints(view: lblGuest) {
            $0.centerY.equalTo(swiHostGuest.snp.centerY)
            $0.leading.equalTo(swiHostGuest.snp.trailing).offset(14)
        }

        view.addWithConstraints(view: line2) {
            $0.leading.equalToSuperview().offset(50)
            $0.trailing.equalToSuperview().offset(-28)
            $0.top.equalTo(swiHostGuest.snp.bottom).offset(10)
            $0.height.equalTo(1)
        }

        view.addWithConstraints(view: menuItemProfile) {
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().offset(-18)
            $0.top.equalTo(line2.snp.bottom).offset(36)
        }

        view.addWithConstraints(view: menuItemEmail) {
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().offset(-18)
            $0.below(menuItemProfile, padding: 24)
        }

        view.addWithConstraints(view: menuItemPhone) {
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().offset(-18)
            $0.below(menuItemEmail, padding: 24)
        }

        view.addWithConstraints(view: menuItemLogout) {
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().offset(-18)
            $0.bottom.equalToSuperview().offset(-44)
        }

        view.addWithConstraints(view: menuItemPrivacy) {
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().offset(-18)
            $0.bottom.equalTo(menuItemLogout.snp.top).offset(-20)
        }

        view.addWithConstraints(view: backArrowButton) {
            $0.trailing.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(50)
            $0.height.equalTo(50)
        }

        view.addWithConstraints(view: profileAreaButton) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalTo(lblPhone.snp.bottom)
        }

        return view
    }()

    lazy var profilePictureView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 33
        view.layer.masksToBounds = true
        view.backgroundColor = .white

        view.addWithConstraints(view: profilePictureImage) {
            $0.edges.equalToSuperview()
        }

        view.snp.makeConstraints {
            $0.width.equalTo(66)
            $0.height.equalTo(66)
        }

        return view
    }()

    lazy var profilePictureImage: Image = {
        let imageView = Image(asset: .iconAccount)
        imageView.contentMode = .scaleAspectFill

        if let imageUrl = User.active?.profile.profilePicture,
           !imageUrl.isEmpty {
            imageView.show(url: imageUrl)
        } else if let image = User.active?.profile.avatar?.base64Image {
            imageView.image = image
        }
        return imageView
    }()

    lazy var lblName = Label(
        style: .normal,
        text: User.active?.profile.fullName ?? "UNKNOWN USER",
        color: .white,
        lines: 0)

    lazy var lblPhone = Label(
        style: .normal,
        text: User.active?.profile.phone ?? User.active?.profile.email ?? "",
        color: .white,
        lines: 0)

    lazy var line1: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = .white.withAlphaComponent(0.5)
        return lineView
    }()

    lazy var line2: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = .white.withAlphaComponent(0.5)
        return lineView
    }()

    lazy var swiHostGuest: UISwitch = {
        let swi = UISwitch()
        swi.isOn = User.active?.role == .guest
        swi.onTintColor = .white
        swi.tintColor = .white
        swi.thumbTintColor = Color.mainDark
        swi.addTarget(self, action: #selector(roleChanged), for: .valueChanged)
        return swi
    }()

    lazy var lblHost = Label(style: .large, text: "HOST", color: .white, lines: 1)

    lazy var lblGuest = Label(style: .large, text: "GUEST", color: .white, lines: 1)

    lazy var menuItemProfile = SidebarMenuItem(asset: .sidebarIconProfile, title: "Profile", delegate: self)

    lazy var menuItemEmail = SidebarMenuItem(asset: .sidebarIconEmail, title: "care@wythyou.com", delegate: self)

    lazy var menuItemPhone = SidebarMenuItem(asset: .sidebarIconPhone, title: "(650)665-4002", delegate: self)

    lazy var menuItemPrivacy = SidebarMenuItem(asset: .sidebarIconPrivacy, title: "Privacy Policy", delegate: self)

    lazy var menuItemLogout = SidebarMenuItem(asset: .sidebarIconSignOut, title: "Logout", delegate: self)

    lazy var backArrowButton: UIButton = {
        let button = UIButton()
        button.setTitle("   ", for: .normal)
        button.setImage(ImageAsset.backArrow.image, for: .normal)
        button.backgroundColor = Color.mainDark
        button.addTarget(self, action: #selector(disappear), for: .touchUpInside)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()

    lazy var profileAreaButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(" ", for: .normal)
        button.addTarget(self, action: #selector(openProfile), for: .touchUpInside)
        return button
    }()

    private init() {
        super.init(frame: UIScreen.main.bounds)

        createLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createLayout() {
        addWithConstraints(view: backgroundButton) {
            $0.edges.equalToSuperview()
        }

        barContainer.transform = CGAffineTransform(translationX: -280, y: 0)
        addWithConstraints(view: barContainer) {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(-16)
            $0.width.equalTo(270)
        }
    }

    func appear() {
        UIView.animate(withDuration: 0.3) {
            self.barContainer.transform = CGAffineTransform.identity
        } completion: { _ in
            self.appeared = true
        }
    }

    @objc func disappear() {
        if !appeared {
            return
        }

        UIView.animate(withDuration: 0.3) {
            self.barContainer.transform = CGAffineTransform(translationX: -280, y: 0)
        } completion: { _ in
            self.appeared = false
            self.removeFromSuperview()
        }
    }

    @discardableResult
    static func createAndShow<L: Layout>(screen: Screen<L>) -> Sidebar<L> {
        let sidebar = Sidebar<L>()
        sidebar.screen = screen
        screen.view.addSubview(sidebar)
        sidebar.appear()
        return sidebar
    }

    @objc func roleChanged() {
        let newRole = swiHostGuest.isOn ?
            UserRole.guest :
            UserRole.host
        User.changeRole(newRole: newRole)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak screen] in
            let firstVC = newRole == .host ?
                HostPanelScreen() : GuestHomeScreen()
            screen?.navigator.replaceStack(newStack: [
                0,
                firstVC
            ])
        }
    }

    @objc func openProfile() {
        disappear()
        screen?.navigator.navigate(to: ProfileScreen.self)
    }
}

extension Sidebar: SidebarMenuItemDelegate {
    func menuItemSelected(_ sidebarMenuItem: SidebarMenuItem) {
        switch sidebarMenuItem {
        case menuItemProfile:
            disappear()
            screen?.navigator.navigate(to: ProfileScreen.self)

        case menuItemEmail:
            screen?.mailSupport()

        case menuItemPhone:
            screen?.callSupport()

        case menuItemPrivacy:
            UIApplication.shared.open(
                URLs.privacyPolicy,
                options: [:],
                completionHandler: nil)

        case menuItemLogout:
            Task {
                await User.logOut()
                await MainActor.run {
                    screen?.navigator.navigate(to: UserTypeSelectorScreen.self)
                }
            }

        default:
            break
        }
    }
}
