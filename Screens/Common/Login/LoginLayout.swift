import UIKit
import SnapKit

class LoginLayout: Layout, CheckBoxDelegate, ButtonDelegate, ImageButtonDelegate {
    lazy var googleLoginButton = Button(
        style: .google, shape: .roundedRectangleWithCorner(corner: 2),
        title: "Sign in with Google",
        image: .googleIcon, delegate: self)

    lazy var appleLoginButton = Button(
        style: .apple, shape: .roundedRectangleWithCorner(corner: 5),
        title: "Sign in with Apple",
        image: .appleIcon, delegate: self)

    lazy var agreeCheckBox = CheckBox(isChecked: false, delegate: self)

    lazy var privacyLabel = Label(style: .normal)

    private var tcRange: NSRange?
    private var ppRange: NSRange?

    private lazy var privacyLabelTapDetector = UITapGestureRecognizer(target: self, action: #selector(labelTapped(gesture:)))

    lazy var privacyBox: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.addWithConstraints(view: agreeCheckBox) {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }

        view.addWithConstraints(view: privacyLabel) {
            $0.top.equalToSuperview()
            $0.leading.equalTo(agreeCheckBox.snp.trailing).offset(8)
            $0.height.greaterThanOrEqualTo(24)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        let text = "Agree to the terms and conditions and privacy policy"
        let attributedText = NSMutableAttributedString(string: text)
        if let range = text.range(of: "terms and conditions") {
            let from = text.distance(from: text.startIndex, to: range.lowerBound)
            let to = text.distance(from: text.startIndex, to: range.upperBound)
            tcRange = NSRange(location: from, length: to - from)
            attributedText.addAttribute(
                .foregroundColor,
                value: Color.main,
                range: tcRange!)
        }
        if let range = text.range(of: "privacy policy") {
            let from = text.distance(from: text.startIndex, to: range.lowerBound)
            let to = text.distance(from: text.startIndex, to: range.upperBound)
            ppRange = NSRange(location: from, length: to - from)
            attributedText.addAttribute(
                .foregroundColor,
                value: Color.main,
                range: ppRange!)
        }
        privacyLabel.attributedText = attributedText
        privacyLabel.isUserInteractionEnabled = true
        privacyLabel.addGestureRecognizer(privacyLabelTapDetector)

        return view
    }()

    lazy var backButton = ImageButton(asset: .backArrow, delegate: self)

    @objc func labelTapped(gesture: UITapGestureRecognizer) {
        if tcRange != nil,
           gesture.didTapAttributedString("terms and conditions", in: privacyLabel) {
            UIApplication.shared.open(
                URLs.termsAndConditions,
                options: [:],
                completionHandler: nil
            )
        }
        if ppRange != nil,
           gesture.didTapAttributedString("privacy policy", in: privacyLabel) {
            UIApplication.shared.open(
                URLs.privacyPolicy,
                options: [:],
                completionHandler: nil
            )
        }
    }

    func checkBoxStatusChanged(checkBox: CheckBox, isChecked: Bool) {
        fatalError("checkBoxStatusChanged must be overridden")
    }

    func buttonClicked(button: Button) {
        fatalError("buttonClicked must be overridden")
    }

    func imageButtonClicked(imageButton: ImageButton) {
        fatalError("imageButtonClicked must be overridden")
    }
}
