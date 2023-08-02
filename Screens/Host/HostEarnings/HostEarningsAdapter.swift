import UIKit

class HostEarningsAdapter: NSObject, UITableViewDelegate, UITableViewDataSource {
    var earnings: [EarningIndexResponseResult] = []

    weak var delegate: EarningCellDelegate?

    init(delegate: EarningCellDelegate) {
        self.delegate = delegate
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        earnings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EarningCell.cellId, for: indexPath)
        if let earningCell = cell as? EarningCell {
            earningCell.prepare(earning: earnings[indexPath.row], delegate: delegate)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        8
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        62
    }
}
