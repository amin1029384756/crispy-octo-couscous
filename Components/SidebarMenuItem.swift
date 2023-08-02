import UIKit

protocol SidebarMenuItemDelegate: AnyObject {
    func menuItemSelected(_ sidebarMenuItem: SidebarMenuItem)
}

class SidebarMenuItem: UIView {
    weak var delegate: SidebarMenuItemDelegate?

    lazy var tapDetector = UITapGestureRecognizer(target: self, action: #selector(tapped))

    lazy var iconImage = Image()

    lazy var titleLabel = Label(style: .large, text: "", color: .white, lines: 1)

    init(asset: ImageAsset, title: String, delegate: SidebarMenuItemDelegate) {
        self.delegate = delegate

        super.init(frame: .zero)

        createLayout(asset: asset, title: title)

        addGestureRecognizer(tapDetector)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createLayout(asset: ImageAsset, title: String) {
        iconImage.setImage(asset: asset)
        iconImage.contentMode = .center
        addWithConstraints(view: iconImage) {
            $0.width.equalTo(24)
            $0.height.equalTo(24)
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        titleLabel.text = title.uppercased()
        titleLabel.textAlignment = .left
        addWithConstraints(view: titleLabel) {
            $0.leading.equalTo(iconImage.snp.trailing).offset(16)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        snp.makeConstraints {
            $0.height.equalTo(24)
        }
    }

    @objc func tapped() {
        delegate?.menuItemSelected(self)
    }
}
