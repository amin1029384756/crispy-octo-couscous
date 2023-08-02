import UIKit

class HostToDoListLayout: Layout {
    lazy var topBar = TopBar(mode: .host, title: "TO-DO LIST", customTopView: nil, delegate: self)

    lazy var bottomBackButton = ShadyBackButton(delegate: self)

    lazy var titleLabel = Label(
        style: .regular,
        text: "to become a host\nplease complete the following steps".uppercased(),
        color: Color.mainText,
        lines: 2)

    lazy var item1Label = Label(
        style: .small,
        text: "1. watch the following youtube tutorial!".uppercased(),
        color: Color.mainText,
        lines: 0)

    lazy var youTubeImageView: UIImageView = {
        let imageView = Image(asset: .youtubeIcon)
        imageView.contentMode = .center
        imageView.backgroundColor = UIColor(hex: 0xF0F0F0)!
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true

        let tapDetector = UITapGestureRecognizer(target: self, action: #selector(watchYouTube))
        imageView.addGestureRecognizer(tapDetector)

        return imageView
    }()

    lazy var item2Label = Label(
        style: .small,
        text: "2. pass the quiz".uppercased(),
        color: Color.mainText,
        lines: 0)

    lazy var item2ImageView = Image(asset: .iconChecklistQuiz)

    lazy var item3Label = Label(
        style: .small,
        text: "3. schedule your interview session".uppercased(),
        color: Color.mainText,
        lines: 0)

    lazy var item3ImageView = Image(asset: .iconChecklistInterview)
    
    lazy var continueButton = Button(
        style: .green,
        shape: .roundedRectangle(height: 46),
        title: "CONTINUE",
        image: nil,
        delegate: self)

    weak var screen: HostToDoListScreen?

    override func createLayout() {
        addWithConstraints(view: topBar) {
            $0.top.equalTo(layoutMarginsGuide.snp.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        titleLabel.textAlignment = .center
        addWithConstraints(view: titleLabel) {
            $0.top.equalTo(topBar.snp.bottom).offset(30)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        addWithConstraints(view: item1Label) {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(48)
            $0.trailing.equalToSuperview().offset(-48)
        }

        addWithConstraints(view: youTubeImageView) {
            $0.top.equalTo(item1Label.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(48)
            $0.trailing.equalToSuperview().offset(-48)
            $0.height.equalTo(136)
        }

        addWithConstraints(view: item2Label) {
            $0.top.equalTo(youTubeImageView.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(48)
            $0.trailing.equalToSuperview().offset(-48)
        }

        item2ImageView.contentMode = .scaleAspectFit
        addWithConstraints(view: item2ImageView) {
            $0.top.equalTo(item2Label.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(48)
            $0.trailing.equalToSuperview().offset(-48)
            $0.height.equalTo(48)
        }

        let item3String = item3Label.attributedText?.string ?? ""
        let attributedString = NSMutableAttributedString(attributedString: item3Label.attributedText ?? NSAttributedString())

        let boldWord = "INTERVIEW SESSION"
        let boldWordRange = (item3String as NSString).range(of: boldWord)
        attributedString.setAttributes([
            .font: LabelStyle.smallBold.font,
            .foregroundColor: Color.main.cgColor
        ], range: boldWordRange)

        item3Label.attributedText = attributedString

        let tapDetector = UITapGestureRecognizer(target: self, action: #selector(scheduleInterview))
        item3Label.addGestureRecognizer(tapDetector)
        item3Label.isUserInteractionEnabled = true
        addWithConstraints(view: item3Label) {
            $0.top.equalTo(item2ImageView.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(48)
            $0.trailing.equalToSuperview().offset(-48)
        }

        item3ImageView.contentMode = .scaleAspectFit
        addWithConstraints(view: item3ImageView) {
            $0.top.equalTo(item3Label.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(48)
            $0.trailing.equalToSuperview().offset(-48)
            $0.height.equalTo(48)
        }

        addWithConstraints(view: bottomBackButton) {
            $0.leading.equalToSuperview().offset(30)
            $0.bottom.equalToSuperview().offset(28)
        }
        
        addWithConstraints(view: continueButton) {
            $0.bottom.equalTo(bottomBackButton.snp.top).offset(8)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(146)
        }
    }

    @objc func watchYouTube() {
        screen?.showYouTubeVideo()
    }

    @objc func scheduleInterview() {
        screen?.scheduleInterview()
    }
}

extension HostToDoListLayout: TopBarDelegate {
    func profileButtonClicked() {
        screen?.openProfile()
    }

    func rightButtonClicked() {
        screen?.openEarnings()
    }
}

extension HostToDoListLayout: ShadyBackButtonDelegate {
    func backTapped() {
        screen?.goBack()
    }
}

extension HostToDoListLayout: ButtonDelegate {
    func buttonClicked(button: Button) {
        switch button {
        case continueButton:
            screen?.goNext()
            
        default:
            break
        }
    }
}
