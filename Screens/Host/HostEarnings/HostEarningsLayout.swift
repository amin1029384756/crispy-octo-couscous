import UIKit

class HostEarningsLayout: Layout {
    lazy var topBar = TopBar(mode: .host, title: "EARNINGS", customTopView: nil, delegate: self)

    lazy var noReservationsLabel = Label(style: .titleLarge, text: "There are no reservations at this moment", color: Color.mainText, lines: 0)

    let refreshControl = UIRefreshControl()

    lazy var list = UITableView()

    lazy var bottomBackButton = ShadyBackButton(delegate: self)

    weak var screen: HostEarningsScreen?

    override func createLayout() {
        addWithConstraints(view: list) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-62)
        }
        list.backgroundColor = .white
        list.register(EarningCell.self, forCellReuseIdentifier: EarningCell.cellId)
        list.separatorStyle = .none
        list.allowsSelection = false

        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        list.addSubview(refreshControl)

        noReservationsLabel.isHidden = true
        addWithConstraints(view: noReservationsLabel) {
            $0.leading.equalTo(list.snp.leading).offset(32)
            $0.trailing.equalTo(list.snp.trailing).offset(-32)
            $0.centerY.equalTo(list.snp.centerY)
        }

        addWithConstraints(view: topBar) {
            $0.top.equalTo(layoutMarginsGuide.snp.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(list.snp.top)
        }

        addWithConstraints(view: bottomBackButton) {
            $0.leading.equalToSuperview().offset(30)
            $0.bottom.equalToSuperview().offset(28)
        }
    }

    @objc func refresh() {
        screen?.refresh()
    }
}

extension HostEarningsLayout: TopBarDelegate {
    func profileButtonClicked() {
        screen?.openProfile()
    }

    func rightButtonClicked() {
        // Already Earnings, no action required
    }
}

extension HostEarningsLayout: ShadyBackButtonDelegate {
    func backTapped() {
        screen?.goBack()
    }
}
