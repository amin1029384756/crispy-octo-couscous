import UIKit

class HostPanelLayout: Layout {
    lazy var topBar = TopBar(mode: .host, title: nil, customTopView: chatButton, delegate: self)

    lazy var chatButton = ChatButton(delegate: self)

    lazy var experienceMenuLabel = Label(
        style: .regular,
        text: "EXPERIENCE MENU",
        color: Color.mainText,
        lines: 1)

    lazy var addANewExperience = Label(
        style: .regular,
        text: "+ ADD A NEW EXPERIENCE",
        color: Color.main,
        lines: 1)

    lazy var addANewExperienceTapDetector = UITapGestureRecognizer(
        target: self,
        action: #selector(addANewExperienceTapped))

    lazy var svExperiences = SwipeView()

    lazy var pageIndicatorView = PageIndicatorView(delegate: nil)

    weak var screen: HostPanelScreen?

    override func createLayout() {
        addWithConstraints(view: topBar) {
            $0.top.equalTo(layoutMarginsGuide.snp.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        addWithConstraints(view: experienceMenuLabel) {
            $0.top.equalTo(topBar.snp.bottom).offset(22)
            $0.centerX.equalToSuperview()
        }

        addANewExperience.isUserInteractionEnabled = true
        addWithConstraints(view: addANewExperience) {
            $0.top.equalTo(experienceMenuLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(38)
        }
        addANewExperience.addGestureRecognizer(addANewExperienceTapDetector)

        addWithConstraints(view: svExperiences) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(addANewExperience.snp.bottom).offset(8)
        }

        addWithConstraints(view: pageIndicatorView) {
            $0.top.equalTo(svExperiences.snp.bottom).offset(6)
            $0.bottom.equalTo(layoutMarginsGuide.snp.bottom).offset(-40)
            $0.centerX.equalToSuperview()
        }
    }

    @objc func addANewExperienceTapped() {
        screen?.addANewExperience()
    }
}

extension HostPanelLayout: TopBarDelegate {
    func profileButtonClicked() {
        screen?.openProfile()
    }

    func rightButtonClicked() {
        screen?.openEarnings()
    }
}

extension HostPanelLayout: ChatButtonDelegate {
    func openChatList() {
        screen?.openChatList()
    }
}
