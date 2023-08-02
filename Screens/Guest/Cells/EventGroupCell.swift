import UIKit

class EventGroupCell: UITableViewCell {
    var expandingTitle = ExpandingTitle(id: "", icon: .iconYoga, title: "", isExpanded: false, delegate: nil)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        createLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createLayout() {
        backgroundColor = .clear
        selectionStyle = .none

        addWithConstraints(view: expandingTitle) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }

    func prepare(eventGroup: SubcategoryResponseResult, isExpanded: Bool) {
        expandingTitle
            .set(id: "\(eventGroup.id)")
            .set(iconBase64: eventGroup.icon)
            .set(title: eventGroup.name)
            .setExpanded(isExpanded)
    }
}
