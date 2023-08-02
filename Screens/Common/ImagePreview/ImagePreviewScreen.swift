import UIKit

class ImagePreviewScreen: ScreenWithInput<ImagePreviewLayout, URL> {
    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self
    }

    override func input(_ argument: URL) {
        loadViewIfNeeded()

        layout.imageView.kf.setImage(with: argument)
    }
}
