import UIKit

protocol GuestHomeAdapterDelegate: AnyObject {
    func groupToggled(eventGroup: SubcategoryResponseResult)
    func eventSelected(event: ExperienceIndexResponseResult)
}

class GuestHomeAdapter: NSObject, UITableViewDelegate, UITableViewDataSource {
    private weak var delegate: GuestHomeAdapterDelegate?

    var items = [Any]()
    var expanded = Set<Int>()

    init(items: [Any], delegate: GuestHomeAdapterDelegate?) {
        self.delegate = delegate

        super.init()

        update(items: items, expanded: expanded)
    }

    func update(items: [Any], expanded: Set<Int>) {
        self.items = items
        self.expanded = expanded
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        if let eventGroup = item as? SubcategoryResponseResult {
            let cell = tableView.dequeueReusableCell(withIdentifier: EventGroupCell.cellId, for: indexPath)
            if let eventGroupCell = cell as? EventGroupCell {
                eventGroupCell.prepare(eventGroup: eventGroup, isExpanded: expanded.contains(eventGroup.id))
            }
            return cell
        } else if let event = item as? ExperienceIndexResponseResult {
            let cell = tableView.dequeueReusableCell(withIdentifier: EventCell.cellId, for: indexPath)
            if let eventCell = cell as? EventCell {
                eventCell.prepare(event: event)
            }
            return cell
        } else {
            fatalError("Incorrect item type")
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = items[indexPath.row]
        if let eventGroup = item as? SubcategoryResponseResult {
            delegate?.groupToggled(eventGroup: eventGroup)
        } else if let event = item as? ExperienceIndexResponseResult {
            delegate?.eventSelected(event: event)
        }
    }
}
