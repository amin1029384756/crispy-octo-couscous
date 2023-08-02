import UIKit

class VideoPreviewLayout: Layout {
    weak var screen: VideoPreviewScreen?

    lazy var playerContainer = UIView()

    lazy var closeButton = Button(
        style: .greenOutline,
        shape: .circle(size: 32),
        title: "",
        image: .closeSmallGreen,
        delegate: self)

    override func createLayout() {
        super.createLayout()

        backgroundColor = .black

        playerContainer.backgroundColor = .clear
        addWithConstraints(view: playerContainer) {
            $0.edges.equalToSuperview()
        }

        addWithConstraints(view: closeButton) {
            $0.leading.equalToSuperview().offset(8)
            $0.top.equalToSuperview().offset(8)
        }
    }
}

extension VideoPreviewLayout: ButtonDelegate {
    func buttonClicked(button: Button) {
        screen?.dismiss(animated: true)
    }
}
