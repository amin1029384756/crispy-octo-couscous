import SnapKit
import UIKit

protocol ComboBoxDateDelegate: AnyObject {
    func comboBoxDateChanged(comboBox: ComboBoxDate, selection: Date)
}

class ComboBoxDate: UIView {
    weak var delegate: ComboBoxDateDelegate?

    var minDate: Date?
    var maxDate: Date?
    var selection: Date

    init(minDate: Date?, maxDate: Date?, selection: Date, delegate: ComboBoxDateDelegate?) {
        self.minDate = minDate
        self.maxDate = maxDate
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

        selectionLabel.text = ComboBoxDate.dateFormat.string(from: selection)
        isUserInteractionEnabled = true
        addGestureRecognizer(tapDetector)
    }

    @objc func tapped() {
        let dialog = DatePickerDialog(
            textColor: Color.mainText,
            buttonColor: Color.main,
            font: LabelStyle.normal.font,
            locale: Locale(identifier: "en_US"),
            showCancelButton: true,
            mode: .date)
        dialog.show("Select date",
            doneButtonTitle: "Done",
            cancelButtonTitle: "Cancel",
            defaultDate: selection,
            minimumDate: minDate,
            maximumDate: maxDate,
            datePickerMode: .date) { [weak self] date in
            guard
                let self = self,
                let date = date
            else { return }
            self.selection = date
            self.selectionLabel.text = ComboBoxDate.dateFormat.string(from: date)
            self.delegate?.comboBoxDateChanged(comboBox: self, selection: date)
        }
    }

    static let dateFormat: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter
    }()
}
