import SnapKit
import UIKit

protocol PQuizAnswerViewDelegate: AnyObject {
    func answerSelected(idx: Int)
}

class QuizAnswerView: UIView {
    var idx: Int
    private weak var delegate: PQuizAnswerViewDelegate?

    var isSelected: Bool {
        set {
            innerSelectionCircle.isHidden = !newValue
        }
        get {
            !innerSelectionCircle.isHidden
        }
    }

    lazy var innerSelectionCircle: UIView = {
        let innerView = UIView()
        innerView.layer.cornerRadius = 5
        innerView.layer.backgroundColor = Color.main.cgColor
        innerView.isHidden = true
        return innerView
    }()

    lazy var selectionCircle: UIView = {
        let outerView = UIView()
        outerView.layer.cornerRadius = 8
        outerView.layer.borderColor = UIColor(hex: 0xB6B6B6)!.cgColor
        outerView.layer.borderWidth = 1

        outerView.addWithConstraints(view: innerSelectionCircle) {
            $0.width.equalTo(10)
            $0.height.equalTo(10)
            $0.center.equalToSuperview()
        }

        return outerView
    }()

    lazy var answerLabel = Label(
        style: .small,
        text: "",
        color: Color.mainText,
        lines: 0)

    lazy var tapDetected = UITapGestureRecognizer(target: self, action: #selector(answerSelected))

    init(idx: Int, answer: String, delegate: PQuizAnswerViewDelegate) {
        self.idx = idx

        super.init(frame: .zero)

        self.delegate = delegate

        addWithConstraints(view: selectionCircle) {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.width.equalTo(16)
            $0.height.equalTo(16)
        }

        answerLabel.text = answer.uppercased()
        addWithConstraints(view: answerLabel) {
            $0.leading.equalTo(selectionCircle.snp.trailing).offset(8)
            $0.top.equalTo(selectionCircle.snp.top).offset(2)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }

        isUserInteractionEnabled = true
        addGestureRecognizer(tapDetected)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func answerSelected() {
        delegate?.answerSelected(idx: idx)
    }
}
