import UIKit
import SnapKit

class HostBecome3Layout: Layout {
    lazy var topBar = TopBar(mode: .host, title: "Become a Host - Information", customTopView: nil, delegate: self)

    lazy var mainScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        scrollView.keyboardDismissMode = .onDrag
        scrollView.addWithConstraints(view: mainScrollableArea) {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }
        return scrollView
    }()

    lazy var mainScrollableArea: UIView = {
        let scrollableArea = UIView()
        scrollableArea.backgroundColor = .clear

        let leftPadding = CGFloat(24)

        let hideKeyboardButton = UIButton(type: .custom)
        hideKeyboardButton.setTitle(" ", for: .normal)
        hideKeyboardButton.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
        scrollableArea.addWithConstraints(view: hideKeyboardButton) {
            $0.edges.equalToSuperview()
        }

        scrollableArea.addWithConstraints(view: introductoryVideoBox) {
            $0.top.equalToSuperview().offset(28)
            $0.leading.equalToSuperview().offset(leftPadding)
            $0.trailing.equalToSuperview().offset(-32)
        }

        scrollableArea.addWithConstraints(view: amountBadge) {
            $0.trailing.equalTo(introductoryVideoBox.snp.trailing).offset(-56)
            $0.top.equalTo(introductoryVideoBox.snp.top).offset(-16)
            $0.width.equalTo(32)
            $0.height.equalTo(32)
        }

        scrollableArea.addWithConstraints(view: addBadge) {
            $0.trailing.equalTo(introductoryVideoBox.snp.trailing).offset(16)
            $0.top.equalTo(introductoryVideoBox.snp.top).offset(-16)
            $0.width.equalTo(32)
            $0.height.equalTo(32)
        }

        descriptionTitleLabel.adjustsFontSizeToFitWidth = true
        scrollableArea.addWithConstraints(view: descriptionTitleLabel) {
            $0.top.equalTo(introductoryVideoBox.snp.bottom).offset(14)
            $0.leading.equalToSuperview().offset(leftPadding)
        }

        scrollableArea.addWithConstraints(view: descriptionDescriptionLabel) {
            $0.top.equalTo(descriptionTitleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(descriptionTitleLabel.snp.leading)
        }

        scrollableArea.addWithConstraints(view: descriptionTextViewBox) {
            $0.top.equalTo(introductoryVideoBox.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(120)
            $0.trailing.equalToSuperview().offset(-32)
            $0.height.equalTo(114)
            $0.leading.equalTo(descriptionTitleLabel.snp.trailing).offset(8)
            $0.leading.equalTo(descriptionDescriptionLabel.snp.trailing).offset(8)
        }

        languageTitleLabel.adjustsFontSizeToFitWidth = true
        scrollableArea.addWithConstraints(view: languageTitleLabel) {
            $0.top.equalTo(descriptionTextViewBox.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(leftPadding)
        }

        scrollableArea.addWithConstraints(view: languageSelectionBox) {
            $0.top.equalTo(descriptionTextViewBox.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(120)
            $0.leading.equalTo(languageTitleLabel).offset(8)
            $0.width.equalTo(100)
        }

        priceTitleLabel.adjustsFontSizeToFitWidth = true
        scrollableArea.addWithConstraints(view: priceTitleLabel) {
            $0.top.equalTo(languageSelectionBox.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(leftPadding)
        }

        scrollableArea.addWithConstraints(view: priceTextField) {
            $0.top.equalTo(languageSelectionBox.snp.bottom).offset(14)
            $0.leading.equalToSuperview().offset(120)
            $0.leading.equalTo(priceTitleLabel).offset(8)
            $0.width.equalTo(40)
            $0.height.equalTo(24)
        }

        durationTitleLabel.adjustsFontSizeToFitWidth = true
        scrollableArea.addWithConstraints(view: durationTitleLabel) {
            $0.top.equalTo(priceTextField.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(leftPadding)
        }

        scrollableArea.addWithConstraints(view: durationTextField) {
            $0.top.equalTo(priceTextField.snp.bottom).offset(14)
            $0.leading.equalToSuperview().offset(120)
            $0.leading.equalTo(durationTitleLabel).offset(8)
            $0.width.equalTo(60)
            $0.height.equalTo(24)
        }

        hostInfo.title.font = LabelStyle.normal.font
        scrollableArea.addWithConstraints(view: hostInfo) {
            $0.below(durationTextField, padding: 16)
            $0.leading.equalToSuperview().offset(leftPadding)
            $0.trailing.equalToSuperview().offset(-32)
        }

        scrollableArea.addWithConstraints(view: continueButton) {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(146)
            $0.bottom.equalToSuperview().offset(-96)
            $0.below(hostInfo, padding: 16)
        }

        return scrollableArea
    }()

    lazy var introductoryVideoBox: UIView = {
        let viewBox = UIView()
        viewBox.backgroundColor = .clear

        viewBox.addWithConstraints(view: introductoryVideoFrame) {
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.width.equalTo(76)
            $0.height.equalTo(112)
        }

        viewBox.addWithConstraints(view: introductoryVideoTitleLabel) {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(introductoryVideoFrame.snp.leading).offset(-8)
        }

        let descriptionString = introductoryVideoDescriptionLabel.attributedText?.string ?? ""
        let attributedString = NSMutableAttributedString(attributedString: introductoryVideoDescriptionLabel.attributedText ?? NSAttributedString())

        let boldWord1 = "PORTRAIT"
        let boldWordRange1 = (descriptionString as NSString).range(of: boldWord1)
        attributedString.setAttributes([
            .font: LabelStyle.smallBold.font
        ], range: boldWordRange1)

        let boldWord2 = "15 SECONDS"
        let boldWordRange2 = (descriptionString as NSString).range(of: boldWord2)
        attributedString.setAttributes([
            .font: LabelStyle.smallBold.font
        ], range: boldWordRange2)

        introductoryVideoDescriptionLabel.attributedText = attributedString
        viewBox.addWithConstraints(view: introductoryVideoDescriptionLabel) {
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(introductoryVideoFrame.snp.leading).offset(-8)
            $0.top.equalTo(introductoryVideoTitleLabel.snp.bottom).offset(8)
        }

        return viewBox
    }()

    lazy var introductoryVideoTitleLabel = Label(
        style: .normal, text: "INTRODUCTORY PHOTOS / VIDEOS: *" /* "INTRODUCTORY VIDEO: *" */,
        color: Color.mainText, lines: 1)

    lazy var introductoryVideoDescriptionLabel = Label(
        style: .small, text: "CHOOSE OR TAKE A PHOTO TO SHOW YOUR AUDIENCE WHY YOU ARE INTERESTED IN OFFERING THIS EXPERIENCE!\nPLEASE CHOOSE UP TO 5 PHOTOS IN PORTRAIT MODE.", // \nPLEASE STRICTLY RECORD YOUR INTRO VIDEO IN PORTRAIT MODE AND KEEP IT UNDER 15 SECONDS!" /* "USE THIS TIME TO RECORD AND TELL YOUR AUDIENCE WHY YOU ARE INTERESTED\nIN OFFERING THIS EXPERIENCE!\n\nPORTRAIT MODE IS REQUIRED!\nTHUMBNAIL IS GOING TO BE THE FIRST FRAME OF YOUR VIDEO" */,
        color: Color.main, lines: 0)

    lazy var introductoryVideoFrame: UIView = {
        let videoView = UIView()
        videoView.backgroundColor = Color.lightGray
        videoView.layer.cornerRadius = 10

        videoView.addWithConstraints(view: videoThumbnail) {
            $0.edges.equalToSuperview()
        }

        videoView.addWithConstraints(view: introductoryVideoSelectButton) {
            $0.edges.equalToSuperview()
        }

        return videoView
    }()

    lazy var videoThumbnail: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()

    lazy var introductoryVideoSelectButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(" ", for: .normal)
        button.addTarget(self, action: #selector(addVideoTapped), for: .touchUpInside)
        return button
    }()

    lazy var amountBadge: Label = {
        let label = Label(
            style: .invoicePrice,
            text: "0",
            color: .white,
            lines: 1)
        label.backgroundColor = Color.main
        label.layer.cornerRadius = 16
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.borderWidth = 2
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()

    lazy var addBadge: Label = {
        let label = Label(
            style: .invoicePrice,
            text: "＋",
            color: .white,
            lines: 1)
        label.backgroundColor = Color.main
        label.layer.cornerRadius = 16
        label.layer.borderColor = UIColor.white.cgColor
        label.layer.borderWidth = 2
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.isUserInteractionEnabled = true
        label.isHidden = true

        let tapDetector = UITapGestureRecognizer(target: self, action: #selector(addVideoTapped))
        label.addGestureRecognizer(tapDetector)

        return label
    }()

    lazy var descriptionTitleLabel = Label(
        style: .normal, text: "DESCRIPTION: *",
        color: Color.mainText, lines: 0)

    lazy var descriptionDescriptionLabel = Label(
        style: .small, text: "DO NOT SHARE YOUR FULL NAME OR CONTACT INFORMATION IN THE DESCRIPTION",
        color: Color.main, lines: 0)

    lazy var descriptionTextViewBox: UIView = {
        let box = UIView()
        box.layer.borderColor = Color.lightGray.cgColor
        box.layer.borderWidth = 1.0
        box.layer.cornerRadius = 10
        box.backgroundColor = Color.lightBackground

        descriptionTextView.backgroundColor = .clear
        descriptionTextView.font = LabelStyle.small.font
        descriptionTextView.textColor = Color.mainText

        box.addWithConstraints(view: descriptionTextView) {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-8)
            $0.bottom.equalToSuperview().offset(-8)
        }

        return box
    }()

    lazy var descriptionTextView = UITextView()

    lazy var languageTitleLabel = Label(
        style: .normal, text: "LANGUAGE: *",
        color: Color.mainText, lines: 1)

    lazy var languageSelectionBox = ComboBox(
        optionList: Lang.list.map { $0.language.uppercased() },
        selection: Lang.list.first?.language.uppercased() ?? "ENGLISH",
        delegate: self)

    lazy var priceTitleLabel = Label(
        style: .normal, text: "PRICE $:",
        color: Color.mainText, lines: 1)

    lazy var priceTextField: UITextField = {
        let textField = UITextField()
        textField.isEnabled = false
        textField.backgroundColor = Color.lightGrayBackground
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = Color.lightGray.cgColor
        textField.layer.cornerRadius = 10

        let paddingView1 = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 24))
        textField.leftView = paddingView1
        textField.leftViewMode = .always

        let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 24))
        textField.rightView = paddingView2
        textField.rightViewMode = .always

        textField.font = LabelStyle.small.font
        textField.textColor = Color.mainText

        return textField
    }()

    lazy var durationTitleLabel = Label(
        style: .normal, text: "DURATION:",
        color: Color.mainText, lines: 1)

    lazy var durationTextField: UITextField = {
        let textField = UITextField()
        textField.isEnabled = false
        textField.backgroundColor = Color.lightGrayBackground
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = Color.lightGray.cgColor
        textField.layer.cornerRadius = 10

        let paddingView1 = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 24))
        textField.leftView = paddingView1
        textField.leftViewMode = .always

        let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 24))
        textField.rightView = paddingView2
        textField.rightViewMode = .always

        let minLabel = Label(
            style: .xxsmall, text: "min",
            color: Color.mainText, lines: 1)

        paddingView2.addWithConstraints(view: minLabel) {
            $0.leading.equalToSuperview().offset(4)
            $0.trailing.equalToSuperview().offset(-4)
            $0.bottom.equalToSuperview().offset(-4)
        }

        textField.font = LabelStyle.small.font
        textField.textColor = Color.mainText

        return textField
    }()

    lazy var hostInfo = HostInfoFormInputView()

    lazy var continueButton = Button(
        style: .green,
        shape: .roundedRectangle(height: 46),
        title: "CONTINUE",
        image: nil,
        delegate: self)

    lazy var bottomBackButton = ShadyBackButton(delegate: self)

    private var mainScrollViewBottomConstraint: ConstraintMakerEditable!

    weak var screen: HostBecome3Screen?

    override func createLayout() {
        addWithConstraints(view: mainScrollView) {
            mainScrollViewBottomConstraint = $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        addWithConstraints(view: topBar) {
            $0.top.equalTo(layoutMarginsGuide.snp.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(mainScrollView.snp.top)
        }

        addWithConstraints(view: bottomBackButton) {
            $0.leading.equalToSuperview().offset(30)
            $0.bottom.equalToSuperview().offset(28)
        }
    }

    @objc func addVideoTapped() {
        screen?.addIntroductoryVideo()
    }

    func showVideo(thumb: UIImage?) {
        videoThumbnail.image = thumb
    }

    @objc func dismissKeyboard() {
        endEditing(true)
    }

    func startObservingKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    @objc private func handleKeyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        mainScrollViewBottomConstraint.constraint.update(offset: -keyboardFrame.size.height)
        layoutIfNeeded()
    }

    @objc private func handleKeyboardWillHide() {
        mainScrollViewBottomConstraint.constraint.update(offset: 0)
        layoutIfNeeded()
    }
}

extension HostBecome3Layout: TopBarDelegate {
    func profileButtonClicked() {
        screen?.openProfile()
    }

    func rightButtonClicked() {
        screen?.openEarnings()
    }
}

extension HostBecome3Layout: ButtonDelegate {
    func buttonClicked(button: Button) {
        switch button {
        case continueButton:
            screen?.goNext()

        default:
            break
        }
    }
}

extension HostBecome3Layout: ShadyBackButtonDelegate {
    func backTapped() {
        screen?.goBack()
    }
}

extension HostBecome3Layout: ComboBoxDelegate {
    func comboBoxSelectionChanged(comboBox: ComboBox, selection: String) {
    }
}
