import UIKit

class GuestWalletPayLayout: Layout {
    private var tcRange: NSRange?
    private var ppRange: NSRange?

    lazy var topBar = TopBar(mode: .guest, title: "Wallet", customTopView: nil, delegate: self)

    lazy var mainScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        scrollView.keyboardDismissMode = .onDrag
        scrollView.addWithConstraints(view: mainScrollableArea) {
            $0.edges.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width)
        }
        return scrollView
    }()

    lazy var mainScrollableArea: UIView = {
        let scrollableArea = UIView()

        scrollableArea.addWithConstraints(view: invoiceView) {
            $0.top.equalToSuperview().offset(42)
            $0.centerX.equalToSuperview()
        }

        scrollableArea.addWithConstraints(view: serviceFeeRow) {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(invoiceView.snp.bottom).offset(24)
        }

        scrollableArea.addWithConstraints(view: taxRow) {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(serviceFeeRow.snp.bottom).offset(16)
        }

        scrollableArea.addWithConstraints(view: totalLabel) {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(taxRow.snp.bottom).offset(16)
        }

        scrollableArea.addWithConstraints(view: payPalImage) {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(totalLabel.snp.bottom).offset(30)
            $0.width.equalTo(120)
            $0.height.equalTo(102)
        }

        scrollableArea.addWithConstraints(view: privacyBox) {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(payPalImage.snp.bottom).offset(22)
            $0.leading.greaterThanOrEqualToSuperview().offset(44)
            $0.trailing.lessThanOrEqualToSuperview().offset(-44)
        }

        scrollableArea.addWithConstraints(view: slidingButton) {
            $0.leading.equalToSuperview().offset(36)
            $0.trailing.equalToSuperview().offset(-36)
            $0.top.equalTo(privacyBox.snp.bottom).offset(16)
            $0.bottom.equalToSuperview().offset(-120)
        }

        return scrollableArea
    }()

    lazy var invoiceView = InvoiceView(reservation: nil, experience: nil, session: nil, allowActions: false, delegate: nil)

    lazy var serviceFeeRow: UIView = {
        let view = UIView()

        view.addWithConstraints(view: serviceFeeTitleLabel) {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        view.addWithConstraints(view: serviceFeeValueLabel) {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        view.snp.makeConstraints {
            $0.width.equalTo(180)
            $0.height.equalTo(20)
        }

        return view
    }()

    lazy var serviceFeeTitleLabel = Label(
        style: .large, text: "Service Fee:",
        color: Color.mainText, lines: 1)

    lazy var serviceFeeValueLabel = Label(
        style: .large, text: "$0.00",
        color: Color.mainText, lines: 1)

    lazy var taxRow: UIView = {
        let view = UIView()

        view.addWithConstraints(view: taxTitleLabel) {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        view.addWithConstraints(view: taxValueLabel) {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        view.snp.makeConstraints {
            $0.width.equalTo(180)
            $0.height.equalTo(20)
        }

        return view
    }()

    lazy var taxTitleLabel = Label(
        style: .large, text: "Tax:",
        color: Color.mainText, lines: 1)

    lazy var taxValueLabel = Label(
        style: .large, text: "$0.00",
        color: Color.mainText, lines: 1)

    lazy var totalLabel = Label(
        style: .totalInvoice, text: "TOTAL  $ 7.00",
        color: Color.mainText, lines: 1)

    lazy var payPalImage: Image = {
        let image = Image(
            asset: .iconPaypal
        )
        image.backgroundColor = Color.lightGray
        image.contentMode = .center
        image.layer.cornerRadius = 12
        image.layer.masksToBounds = true
        return image
    }()

    lazy var agreeCheckBox = CheckBox(isChecked: false, delegate: self)

    lazy var privacyLabel = Label(style: .normal)

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

    lazy var slidingButton = SlidingButton(amount: 100, delegate: self)

    lazy var bottomBackButton = ShadyBackButton(delegate: self)

    weak var screen: GuestWalletPayScreen?

    override func createLayout() {
        addWithConstraints(view: topBar) {
            $0.top.equalTo(layoutMarginsGuide.snp.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        addWithConstraints(view: mainScrollView) {
            $0.top.equalTo(topBar.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        addWithConstraints(view: bottomBackButton) {
            $0.leading.equalToSuperview().offset(30)
            $0.bottom.equalToSuperview().offset(28)
        }
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

extension GuestWalletPayLayout: TopBarDelegate {
    func profileButtonClicked() {
        screen?.openProfile()
    }

    func rightButtonClicked() {
        screen?.openWallet()
    }
}

extension GuestWalletPayLayout: CheckBoxDelegate {
    func checkBoxStatusChanged(checkBox: CheckBox, isChecked: Bool) {
        screen?.acceptedTerms = isChecked
    }
}

extension GuestWalletPayLayout: ShadyBackButtonDelegate {
    func backTapped() {
        screen?.goBack()
    }
}

extension GuestWalletPayLayout: SlidingButtonDelegate {
    func slided() {
        screen?.pay()
    }
}
