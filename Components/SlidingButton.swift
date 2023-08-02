import SnapKit
import UIKit

protocol SlidingButtonDelegate: AnyObject {
    func slided()
}

class SlidingButton: UIView {
    lazy var swipeToPayLabel = Label(style: .sliderButton, text: "SWIPE TO PAY", color: .white, lines: 1)

    lazy var swipeHandler: UIButton = {
        let button = UIButton()
        button.setImage(
            ImageAsset.swipeHandlerActive.image,
            for: .normal)
        button.addTarget(
            self,
            action: #selector(touchDown(sender:forEvent:)),
            for: .touchDown)
        button.addTarget(
            self,
            action: #selector(touchUp),
            for: .touchUpInside)
        button.addTarget(
            self,
            action: #selector(touchUp),
            for: .touchUpOutside)
        button.addTarget(
            self,
            action: #selector(dragged(sender:forEvent:)),
            for: .touchDragInside)
        button.addTarget(
            self,
            action: #selector(dragged(sender:forEvent:)),
            for: .touchDragOutside)
        return button
    }()

    var canBeSlided = true
    var isMoving = false
    var startLocation: CGPoint?
    var currentOffset = CGFloat(0)
    weak var delegate: SlidingButtonDelegate?

    init(text: String, delegate: SlidingButtonDelegate?) {
        self.delegate = delegate

        super.init(frame: .zero)

        createLayout()

        show(text: text)
    }

    init(amount: Double, delegate: SlidingButtonDelegate?) {
        self.delegate = delegate

        super.init(frame: .zero)

        createLayout()

        show(amount: amount)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createLayout() {
        layer.cornerRadius = 25
        layer.masksToBounds = true
        backgroundColor = Color.main

        addWithConstraints(view: swipeToPayLabel) {
            $0.centerX.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }

        addWithConstraints(view: swipeHandler) {
            $0.width.equalTo(53)
            $0.height.equalTo(52)
            $0.leading.equalToSuperview().offset(5)
            $0.centerY.equalToSuperview().offset(4)
        }

        snp.makeConstraints {
            $0.height.equalTo(50)
        }
    }

    func show(amount: Double) {
        backgroundColor = Color.main
        if amount < 0.01 {
            swipeToPayLabel.text = "SWIPE TO BOOK FOR FREE"
        } else {
            swipeToPayLabel.text = String(format: "SWIPE TO PAY $%.02f", amount)
        }
    }

    func show(text: String) {
        backgroundColor = Color.main
        swipeToPayLabel.text = text
    }

    @objc func touchDown(sender: UIButton, forEvent event: UIEvent) {
        if !canBeSlided {
            return
        }
        if let location = event.allTouches?.first?.location(in: sender) {
            isMoving = true
            startLocation = location
            canBeSlided = false
            print(location)
        }
    }

    @objc func touchUp() {
        isMoving = false

        if currentOffset >= bounds.width - swipeHandler.bounds.width - 50 {
            delegate?.slided()
        }

        UIView.animate(withDuration: 0.3) {
            self.swipeHandler.transform = CGAffineTransform.identity
        } completion: { _ in
            self.canBeSlided = true
            self.currentOffset = CGFloat(0)
        }
    }

    @objc func dragged(sender: UIButton, forEvent event: UIEvent) {
        guard isMoving,
              let startLocation = startLocation
        else {
            return
        }

        if let location = event.allTouches?.first?.location(in: sender) {
            currentOffset += location.x - startLocation.x
            if currentOffset < 0 {
                currentOffset = 0
            }
            if currentOffset >= bounds.width - swipeHandler.bounds.width - 10 {
                currentOffset = bounds.width - swipeHandler.bounds.width - 10
            }
            swipeHandler.transform = CGAffineTransform(translationX: currentOffset, y: 0)
        }
    }
}
