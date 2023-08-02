import UIKit

class GuestBookedExperiencesLayout: Layout {
    lazy var topBar = TopBar(mode: .guest, title: "BOOKED EXPERIENCES", customTopView: nil, delegate: self)

    lazy var yourTicketsLabel = Label(
        style: .regular,
        text: "YOUR TICKETS",
        color: Color.mainText,
        lines: 1)

    lazy var svReservations = SwipeView()

    lazy var pageIndicatorView = PageIndicatorView(delegate: nil)

    lazy var bottomBackButton = ShadyBackButton(delegate: self)

    weak var screen: GuestBookedExperiencesScreen?

    override func createLayout() {
        addWithConstraints(view: topBar) {
            $0.top.equalTo(layoutMarginsGuide.snp.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        addWithConstraints(view: yourTicketsLabel) {
            $0.top.equalTo(topBar.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
        }

        svReservations.alignment = .center
        addWithConstraints(view: svReservations) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(230)
            $0.top.equalTo(yourTicketsLabel.snp.bottom).offset(30)
        }

        addWithConstraints(view: pageIndicatorView) {
            $0.top.equalTo(svReservations.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }

        addWithConstraints(view: bottomBackButton) {
            $0.leading.equalToSuperview().offset(30)
            $0.bottom.equalToSuperview().offset(28)
        }
    }
}

extension GuestBookedExperiencesLayout: ShadyBackButtonDelegate {
    func backTapped() {
        screen?.goBack()
    }
}

extension GuestBookedExperiencesLayout: TopBarDelegate {
    func profileButtonClicked() {
        screen?.openProfile()
    }

    func rightButtonClicked() {
        // Already a wallet screen, nothing to do
    }
}
