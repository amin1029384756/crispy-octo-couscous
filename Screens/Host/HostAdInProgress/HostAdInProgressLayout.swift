import UIKit

class HostAdInProgressLayout: Layout {
    lazy var topBar = TopBar(mode: .host, title: "Become a Host - Ad In progress", customTopView: nil, delegate: self)

    lazy var doneImage = Image(asset: .doneBigHost)

    lazy var receivedLabel = Label(
        style: .congratsLine2,
        text: "WE JUST RECEIVED YOUR AD!",
        color: Color.mainText,
        lines: 1)

    lazy var willBePublishedLabel = Label(
        style: .regular,
        text: "It will be published after approval",
        color: Color.mainText,
        lines: 1)

    lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle(" ", for: .normal)
        button.addTarget(self, action: #selector(returnToMain), for: .touchUpInside)
        return button
    }()

    weak var screen: HostAdInProgressScreen?

    override func createLayout() {
        addWithConstraints(view: topBar) {
            $0.top.equalTo(layoutMarginsGuide.snp.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        addWithConstraints(view: doneImage) {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(topBar.snp.bottom).offset(100)
        }

        addWithConstraints(view: receivedLabel) {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(doneImage.snp.bottom).offset(22)
        }

        addWithConstraints(view: willBePublishedLabel) {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(receivedLabel.snp.bottom).offset(8)
        }

        addWithConstraints(view: nextButton) {
            $0.top.equalTo(topBar.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    @objc func returnToMain() {
        screen?.returnToMain()
    }
}

extension HostAdInProgressLayout: TopBarDelegate {
    func profileButtonClicked() {
        screen?.openProfile()
    }

    func rightButtonClicked() {
        screen?.openEarnings()
    }
}
