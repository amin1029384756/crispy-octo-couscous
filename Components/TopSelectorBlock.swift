import UIKit
import SnapKit

class TopSelectorBlock: UIView {
    lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.snp.makeConstraints {
            $0.width.equalTo(32)
            $0.height.equalTo(32)
        }
        imageView.contentMode = .center
        return imageView
    }()

    lazy var titleLabel = Label(style: .smallNormal, text: "", color: Color.mainText, lines: 1)

    init(title: String, icon: ImageAsset) {
        super.init(frame: .zero)

        iconView.image = icon.image.withRenderingMode(.alwaysTemplate)
        addWithConstraints(view: iconView) {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }

        titleLabel.text = title
        addWithConstraints(view: titleLabel) {
            $0.fillHorizontally()
            $0.bottom.equalToSuperview()
            $0.below(iconView)
            $0.height.equalTo(20)
        }

        setSelected(false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSelected(_ isSelected: Bool) {
        if isSelected {
            iconView.tintColor = Color.main
            titleLabel.textColor = Color.main
        } else {
            iconView.tintColor = Color.mainText.withAlphaComponent(0.9)
            titleLabel.textColor = Color.mainText.withAlphaComponent(0.9)
        }
    }
}
