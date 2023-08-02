import SnapKit
import UIKit

class UserTypeSelectorLayout: Layout {
    lazy var gap1 = UIView()

    lazy var hostImageButton = ImageButton(asset: .selectorHost, delegate: self)

    lazy var gap2 = UIView()

    lazy var separator = Image(asset: .selectorDivider)

    lazy var guestImageButton = ImageButton(asset: .selectorGuest, delegate: self)

    weak var screen: UserTypeSelectorScreen?

    override func createLayout() {
        addWithConstraints(view: gap1) {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        addWithConstraints(view: guestImageButton) {
            $0.leading.equalToSuperview().offset(-8)
            $0.top.equalTo(gap1.snp.bottom)
        }

        addWithConstraints(view: gap2) {
            $0.top.equalTo(guestImageButton.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(gap1.snp.height)
        }

        addWithConstraints(view: separator) {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(gap2.snp.bottom)
        }

        addWithConstraints(view: hostImageButton) {
            $0.trailing.equalToSuperview().offset(16)
            $0.top.equalTo(separator.snp.bottom).offset(54)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-44)
        }
    }
}

extension UserTypeSelectorLayout: ImageButtonDelegate {
    func imageButtonClicked(imageButton: ImageButton) {
        switch imageButton {
        case hostImageButton:
            screen?.hostSelected()

        case guestImageButton:
            screen?.guestSelected()

        default:
             break
        }
    }
}
