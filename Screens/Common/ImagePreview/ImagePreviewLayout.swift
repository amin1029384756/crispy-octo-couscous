import UIKit

class ImagePreviewLayout: Layout {
    weak var screen: ImagePreviewScreen?

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()

        scrollView.addWithConstraints(view: imageView) {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalToSuperview()
        }

        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.delegate = self

        return scrollView
    }()

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var closeButton = Button(
        style: .greenOutline,
        shape: .circle(size: 32),
        title: "",
        image: .closeSmallGreen,
        delegate: self)

    override func createLayout() {
        super.createLayout()

        backgroundColor = .black

        addWithConstraints(view: scrollView) {
            $0.edges.equalToSuperview()
        }

        addWithConstraints(view: closeButton) {
            $0.leading.equalToSuperview().offset(8)
            $0.top.equalToSuperview().offset(8)
        }
    }
}

extension ImagePreviewLayout: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

extension ImagePreviewLayout: ButtonDelegate {
    func buttonClicked(button: Button) {
        screen?.dismiss(animated: true)
    }
}
