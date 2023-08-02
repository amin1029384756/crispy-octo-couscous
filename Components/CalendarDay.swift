import SnapKit
import UIKit

protocol CalendarDelegate: AnyObject {
    func daySelectedInCalendar(date: Date)
}

class CalendarDay: UIView {
    weak var delegate: CalendarDelegate?
    var date: Date

    lazy var tapDetector = UITapGestureRecognizer(target: self, action: #selector(tapped))

    lazy var selectionCircle: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 17.5
        view.layer.masksToBounds = true
        view.layer.borderColor = Color.mainDark.cgColor
        view.layer.borderWidth = 1.0
        view.backgroundColor = Color.mainDark
        view.snp.makeConstraints {
            $0.width.equalTo(35)
            $0.height.equalTo(35)
        }
        return view
    }()

    lazy var dateLabel = Label(
        style: .normal, text: "0",
        color: .darkText, lines: 1)

    init(date: Date, hasAvailableSlots: Bool, isSelected: Bool, delegate: CalendarDelegate?) {
        self.date = date
        self.delegate = delegate

        super.init(frame: .zero)

        createLayout()

        show(date: date, hasAvailableSlots: hasAvailableSlots, isSelected: isSelected)

        addGestureRecognizer(tapDetector)
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func show(date: Date, hasAvailableSlots: Bool, isSelected: Bool) {
        let calendar = Calendar(identifier: .gregorian)
        let day = calendar.component(.day, from: date)
        dateLabel.text = "\(day)"
        selectionCircle.isHidden = !isSelected && !hasAvailableSlots
        if isSelected {
            selectionCircle.backgroundColor = Color.mainDark
        } else {
            selectionCircle.backgroundColor = .white
        }
        dateLabel.textColor = isSelected ? .white : Color.mainText
    }

    private func createLayout() {
        addWithConstraints(view: selectionCircle) {
            $0.center.equalToSuperview()
        }

        addWithConstraints(view: dateLabel) {
            $0.center.equalToSuperview()
        }

        snp.makeConstraints {
            $0.height.equalTo(35)
        }
    }

    @objc func tapped() {
        delegate?.daySelectedInCalendar(date: date)
    }
}
