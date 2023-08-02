import SnapKit
import UIKit

class SplashLayout: Layout {
    lazy var logoImage = Image(asset: .wythYouLogo)

    lazy var logoImageText = Image(asset: .wythYouLogoText)

    lazy var underline = Image(asset: .splashUnderline)

    override func createLayout() {
        addWithConstraints(view: logoImage) {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-24)
        }

        addWithConstraints(view: logoImageText) {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(logoImage.snp.bottom).offset(14)
        }

        addWithConstraints(view: underline) {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(logoImageText.snp.bottom).offset(7)
        }
    }
}
