import UIKit

class GuestBookSuccessLayout: Layout {
    lazy var topBar = TopBar(mode: .guest, title: "SUCCESSFUL PURCHASE", customTopView: nil, delegate: self)

    lazy var backButton = ImageButton(asset: .backCircleBig, delegate: self)

    lazy var congratsLabel = Label(
        style: .congrats, text: "Congrats!",
        color: Color.mainText, lines: 1)

    lazy var contratsLine2Label = Label(
        style: .congratsLine2,
        text: "Experience Successfully Booked!",
        color: Color.mainText, lines: 1)

    lazy var doneBigImage = Image(asset: .doneBig)

    weak var screen: GuestBookSuccessScreen?

    override func createLayout() {
        addWithConstraints(view: topBar) {
            $0.top.equalTo(layoutMarginsGuide.snp.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        addWithConstraints(view: backButton) {
            $0.bottom.equalTo(layoutMarginsGuide.snp.bottomMargin).offset(-64)
            $0.centerX.equalToSuperview()
        }

        addWithConstraints(view: congratsLabel) {
            $0.center.equalToSuperview()
        }

        addWithConstraints(view: contratsLine2Label) {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(congratsLabel.snp.bottom).offset(8)
        }

        addWithConstraints(view: doneBigImage) {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(congratsLabel.snp.top).offset(-8)
        }
    }
}

extension GuestBookSuccessLayout: TopBarDelegate {
    func profileButtonClicked() {
        screen?.openProfile()
    }

    func rightButtonClicked() {
        screen?.openWallet()
    }
}

extension GuestBookSuccessLayout: ImageButtonDelegate {
    func imageButtonClicked(imageButton: ImageButton) {
        screen?.returnHome()
    }
}
