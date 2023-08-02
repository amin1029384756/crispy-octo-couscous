import SnapKit
import UIKit

protocol ComboBoxDelegate: AnyObject {
    func comboBoxSelectionChanged(comboBox: ComboBox, selection: String)
}

class ComboBox: UIView {
    weak var delegate: ComboBoxDelegate?

    var optionList: [String]
    var selection: String {
        didSet {
            selectionLabel.text = selection
        }
    }

    init(optionList: [String], selection: String, delegate: ComboBoxDelegate?) {
        self.optionList = optionList
        self.selection = selection
        self.delegate = delegate

        super.init(frame: .zero)

        createLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var selectionLabel = Label(
        style: .small, text: "",
        color: Color.mainText, lines: 1)

    lazy var arrowImage = Image(
        asset: .triangleDown, tint: Color.mainText)

    lazy var tapDetector = UITapGestureRecognizer(
        target: self,
        action: #selector(tapped))

    private func createLayout() {
        layer.borderColor = Color.lightGray.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 10
        backgroundColor = Color.lightBackground

        addWithConstraints(view: selectionLabel) {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(12)
        }

        addWithConstraints(view: arrowImage) {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(selectionLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-8)
            $0.width.equalTo(8)
            $0.height.equalTo(8)
        }

        snp.makeConstraints {
            $0.height.equalTo(24)
        }

        selectionLabel.text = selection
        isUserInteractionEnabled = true
        addGestureRecognizer(tapDetector)
    }

    @objc func tapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        for optionItem in optionList {
            alert.addAction(UIAlertAction(title: optionItem, style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.selection = optionItem
                self.delegate?.comboBoxSelectionChanged(comboBox: self, selection: optionItem)
                self.selectionLabel.text = optionItem
            })
        }
        parentViewController?.present(alert, animated: true)
    }
}
