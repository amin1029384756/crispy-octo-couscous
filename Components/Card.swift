import SnapKit
import UIKit

class Card: UIView {
    init() {
        super.init(frame: .zero)

        layer.cornerRadius = 6
        layer.masksToBounds = true
        backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
