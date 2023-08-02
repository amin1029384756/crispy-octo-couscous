import UIKit

class HostLoginLayout: LoginLayout {
    lazy var titleLabel = Label(style: .screenTitle, text: "HOST")

    weak var screen: HostLoginScreen?

    override func createLayout() {
        addWithConstraints(view: titleLabel) {
            $0.top.equalTo(layoutMarginsGuide.snp.topMargin).offset(40)
            $0.centerX.equalToSuperview()
        }

        googleLoginButton.titleLabel?.font = Font.bold[15]
        addWithConstraints(view: googleLoginButton) {
            $0.centerY.equalToSuperview()
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
