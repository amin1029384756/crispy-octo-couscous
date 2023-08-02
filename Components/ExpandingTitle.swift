import SnapKit
import UIKit

protocol ExpandingTitleDelegate: AnyObject {
    func changedExpandingTitle(id: String, isExpanded: Bool)
}

class ExpandingTitle: UIView {
    private var id: String
    private var isExpanded: Bool
    private weak var delegate: ExpandingTitleDelegate?

    lazy var iconView = Image()

    lazy var titleLabel = Label(style: .groupTitle, text: "", color: Color.main, lines: 1)

    lazy var expandIconView = Image()

    private var gestureDetector: UITapGestureRecognizer!

    init(id: String, icon: ImageAsset, title: String, isExpanded: Bool, delegate: ExpandingTitleDelegate?) {
        self.id = id
        self.isExpanded = isExpanded
        self.delegate = delegate

        super.init(frame: .zero)

        addWithConstraints(view: titleLabel) {
            $0.center.equalToSuperview()
        }
        titleLabel.text = title

        addWithConstraints(view: iconView) {
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().offset(8)
            $0.width.equalTo(16)
            $0.height.equalTo(16)
            $0.trailing.equalTo(titleLabel.snp.leading).offset(-8)
        }
        iconView.setImage(asset: icon, tint: Color.main)

        addWithConstraints(view: expandIconView) {
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview().offset(-8)
            $0.width.equalTo(10)
            $0.height.equalTo(10)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(8)
        }
        if isExpanded {
            expandIconView.setImage(asset: .triangleUp)
        } else {
            expandIconView.setImage(asset: .triangleDown)
        }

        snp.makeConstraints {
            $0.height.equalTo(32)
        }

        if delegate != nil {
            gestureDetector = UITapGestureRecognizer(target: self, action: #selector(tapped))
            addGestureRecognizer(gestureDetector)
        }
    }

    @discardableResult
    func set(id: String) -> ExpandingTitle {
        self.id = id
        return self
    }

    @discardableResult
    func set(icon: ImageAsset) -> ExpandingTitle {
        self.iconView.setImage(asset: icon, tint: Color.main)
        return self
    }

    @discardableResult
    func set(iconBase64: String) -> ExpandingTitle {
        if let image = iconBase64.base64Image?
            .withRenderingMode(.alwaysTemplate) {
            self.iconView.image = image
            self.iconView.tintColor = Color.main
        }
        return self
    }

    @discardableResult
    func set(title: String) -> ExpandingTitle {
        self.titleLabel.text = title
        return self
    }

    @discardableResult
    func setExpanded(_ isExpanded: Bool) -> ExpandingTitle {
        self.isExpanded = isExpanded
        if isExpanded {
            expandIconView.setImage(asset: .triangleUp)
        } else {
            expandIconView.setImage(asset: .triangleDown)
        }
        return self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func tapped() {
        isExpanded = !isExpanded
        if isExpanded {
            expandIconView.setImage(asset: .triangleUp)
        } else {
            expandIconView.setImage(asset: .triangleDown)
        }
        delegate?.changedExpandingTitle(id: id, isExpanded: isExpanded)
    }
}
