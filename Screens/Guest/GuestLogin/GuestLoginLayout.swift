import UIKit

class GuestLoginLayout: LoginLayout {
    lazy var titleLabel = Label(style: .screenTitle, text: "GUEST")

    lazy var lookMan = Image(asset: .guestMan)

    lazy var lookAroundButton = Button(
        style: .blue, shape: .roundedRectangle(height: 48),
        title: "look around".uppercased(),
        image: nil, delegate: self)

    weak var screen: GuestLoginScreen?

    override func createLayout() {
        addWithConstraints(view: titleLabel) {
            $0.top.equalTo(layoutMarginsGuide.snp.topMargin).offset(40)
            $0.centerX.equalToSuperview()
        }

        lookMan.isHidden = true
        addWithConstraints(view: lookMan) {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.equalToSuperview().offset(41)
        }

        lookAroundButton.isHidden = true
        addWithConstraints(view: lookAroundButton) {
            $0.top.equalTo(lookMan.snp.top).offset(80)
            $0.leading.equalToSuperview().offset(56)
            $0.trailing.equalToSuperview().offset(-42)
        }

        googleLoginButton.titleLabel?.font = Font.bold[15]
        addWithConstraints(view: googleLoginButton) {
            $0.centerY.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
            $0.height.equalTo(42)
        }

        appleLoginButton.titleLabel?.font = Font.medium[15]
        appleLoginButton.tintColor = .white
        appleLoginButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 7)
        appleLoginButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 0)
        addWithConstraints(view: appleLoginButton) {
            $0.bottom.equalTo(googleLoginButton.snp.top).offset(-12)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
            $0.height.equalTo(42)
        }

        addWithConstraints(view: privacyBox) {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(googleLoginButton.snp.bottom).offset(22)
            $0.leading.greaterThanOrEqualToSuperview().offset(44)
            $0.trailing.lessThanOrEqualToSuperview().offset(-44)
        }

        addWithConstraints(view: backButton) {
            $0.leading.equalToSuperview().offset(30)
            $0.bottom.equalTo(layoutMarginsGuide.snp.bottom).offset(-40)
            $0.width.equalTo(32)
            $0.height.equalTo(32)
        }
    }

    override func checkBoxStatusChanged(checkBox: CheckBox, isChecked: Bool) {
        screen?.isAgreed = isChecked
    }

    override func buttonClicked(button: Button) {
        switch button {
        case lookAroundButton:
            screen?.lookAround()

        case googleLoginButton:
            screen?.startGoogleLogin()

        case appleLoginButton:
            screen?.startAppleLogin()

        default:
            break
        }
    }

    override func imageButtonClicked(imageButton: ImageButton) {
        screen?.goBack()
    }
}
