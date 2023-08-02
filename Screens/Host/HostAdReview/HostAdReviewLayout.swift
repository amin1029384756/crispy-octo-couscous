import UIKit

class HostAdReviewLayout: Layout {
    private var tcRange: NSRange?
    private var ppRange: NSRange?

    lazy var topBar = TopBar(mode: .host, title: "Become a Host - Ad Review", customTopView: nil, delegate: self)

    lazy var bottomBackButton = ShadyBackButton(delegate: self)

    lazy var reviewExperienceLabel = Label(
        style: .regular,
        text: "REVIEW THE EXPERIENCE INFO!",
        color: Color.mainText,
        lines: 1)

    lazy var experienceView = HostPanelExperienceView(experience: nil, delegate: nil, isReady: false)

    lazy var agreeCheckBox = CheckBox(isChecked: false, delegate: self)

    lazy var privacyLabel = Label(style: .normal)

    lazy var ageCheckBox = CheckBox(isChecked: false, delegate: self)

    lazy var ageLabel = Label(style: .normal)

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
            $0.trailing.lessThanOrEqualToSuperview()
            $0.bottom.equalToSuperview()
        }
        let text = "By swiping you confirm that you agree to our terms of use and privacy policy"
        let attributedText = NSMutableAttributedString(string: text)
        if let range = text.range(of: "terms of use") {
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

    lazy var ageBox: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.addWithConstraints(view: ageCheckBox) {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }

        view.addWithConstraints(view: ageLabel) {
            $0.top.equalToSuperview()
            $0.leading.equalTo(ageCheckBox.snp.trailing).offset(8)
            $0.height.greaterThanOrEqualTo(24)
            $0.trailing.lessThanOrEqualToSuperview()
            $0.bottom.equalToSuperview()
        }
        ageLabel.text = "I confirm that I am over 18 years old"

        return view
    }()

    lazy var slidingButton = SlidingButton(amount: 100, delegate: self)

    weak var screen: HostAdReviewScreen?

    override func createLayout() {
        addWithConstraints(view: topBar) {
            $0.top.equalTo(layoutMarginsGuide.snp.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        addWithConstraints(view: reviewExperienceLabel) {
            $0.top.equalTo(topBar.snp.bottom).offset(22)
            $0.centerX.equalToSuperview()
        }

        addWithConstraints(view: experienceView) {
            $0.top.equalTo(reviewExperienceLabel.snp.bottom).offset(22)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        addWithConstraints(view: privacyBox) {
            $0.top.equalTo(experienceView.snp.bottom).offset(22)
            $0.leading.greaterThanOrEqualToSuperview().offset(44)
            $0.trailing.lessThanOrEqualToSuperview().offset(-44)
            $0.height.equalTo(32)
        }

        addWithConstraints(view: ageBox) {
            $0.top.equalTo(privacyBox.snp.bottom).offset(8)
            $0.leading.greaterThanOrEqualToSuperview().offset(44)
            $0.trailing.lessThanOrEqualToSuperview().offset(-44)
            $0.height.equalTo(24)
        }

        slidingButton.show(text: "SWIPE TO GENERATE YOUR AD!")
        addWithConstraints(view: slidingButton) {
            $0.leading.equalToSuperview().offset(36)
            $0.trailing.equalToSuperview().offset(-36)
            $0.top.equalTo(ageBox.snp.bottom).offset(16)
            $0.bottom.equalToSuperview().offset(-100)
        }

        addWithConstraints(view: bottomBackButton) {
            $0.leading.equalToSuperview().offset(30)
            $0.bottom.equalToSuperview().offset(28)
        }
    }

    func showExperiencePreview(experience: ExperienceIndexResponseResult, thumb: UIImage?) {
        experienceView.set(experience: experience, thumb: thumb, delegate: self)
    }

    @objc func labelTapped(gesture: UITapGestureRecognizer) {
        if tcRange != nil,
           gesture.didTapAttributedString("terms of use", in: privacyLabel) {
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
}

extension HostAdReviewLayout: ShadyBackButtonDelegate {
    func backTapped() {
        screen?.goBack()
    }
}

extension HostAdReviewLayout: TopBarDelegate {
    func profileButtonClicked() {
        screen?.openProfile()
    }

    func rightButtonClicked() {
        screen?.openEarnings()
    }
}

extension HostAdReviewLayout: SlidingButtonDelegate {
    func slided() {
        screen?.generateAd()
    }
}

extension HostAdReviewLayout: CheckBoxDelegate {
    func checkBoxStatusChanged(checkBox: CheckBox, isChecked: Bool) {
        switch checkBox {
        case agreeCheckBox:
            screen?.acceptedTerms = isChecked

        case ageCheckBox:
            screen?.confirmedAge = isChecked

        default:
            break
        }
    }
}

extension HostAdReviewLayout: HostPanelExperienceViewDelegate {
    func edit(experience: ExperienceIndexResponseResult) {
        screen?.goBack()
    }

    func share(experience: ExperienceIndexResponseResult) {
        // No such button on this screen
        // No action required
    }

    func delete(experience: ExperienceIndexResponseResult) {
        // No such button on this screen
        // No action required
    }
}
