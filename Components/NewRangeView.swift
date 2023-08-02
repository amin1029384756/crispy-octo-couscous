import UIKit

protocol NewRangeViewDelegate: AnyObject {
    func addRange()
}

class NewRangeView: UIView {
    weak var delegate: NewRangeViewDelegate?

    lazy var addLabel = Label(
        style: .xsmall,
        text: "+ADD ANOTHER\nTIME BLOCK",
        color: Color.main,
        lines: 2)

    lazy var tapDetector = UITapGestureRecognizer(target: self, action: #selector(tapped))

    init(delegate: NewRangeViewDelegate?) {
        super.init(frame: .zero)

        self.delegate = delegate

        addWithConstraints(view: addLabel) {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(6)
            $0.trailing.equalToSuperview().offset(-6)
        }

        snp.makeConstraints {
            $0.height.equalTo(30)
        }

        addLabel.textAlignment = .center
        addLabel.isUserInteractionEnabled = true

        addLabel.addGestureRecognizer(tapDetector)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func tapped() {
        delegate?.addRange()
    }
}
