import SnapKit
import UIKit

protocol DayInSliderDelegate: AnyObject {
    func dateSelected(_ date: Date)
}

class DayInSlider: UIView {
    var date: Date
    weak var delegate: DayInSliderDelegate?

    lazy var tapDetector = UITapGestureRecognizer(target: self, action: #selector(tapped))

    lazy var weekDayLabel = Label(style: .large, text: "", color: Color.titleText, lines: 1)

    lazy var dayNumberLabel = Label(style: .dayNumber, text: "", color: Color.titleText, lines: 1)

    init(date: Date, isSelected: Bool, delegate: DayInSliderDelegate?) {
        self.date = date
        self.delegate = delegate

        super.init(frame: .zero)

        createLayout()

        let calendar = Calendar(identifier: .gregorian)
        if calendar.isDateInToday(date) {
            weekDayLabel.text = "TODAY"
        } else {
            let weekDayIndex = calendar.component(.weekday, from: date)
            let weekDays = ["", "SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
            weekDayLabel.text = weekDays[weekDayIndex]
        }
        dayNumberLabel.text = "\(calendar.component(.day, from: date))"

        setSelected(isSelected)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSelected(_ isSelected: Bool) {
        if isSelected {
            backgroundColor = Color.mainDark
            weekDayLabel.textColor = .white
            dayNumberLabel.textColor = .white
            layer.borderColor = Color.mainDark.cgColor
        } else {
            backgroundColor = .white
            weekDayLabel.textColor = Color.titleText
            dayNumberLabel.textColor = Color.titleText
            layer.borderColor = Color.lightBorder.cgColor
        }
    }

    private func createLayout() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.borderWidth = 1

        addWithConstraints(view: weekDayLabel) {
            $0.top.equalToSuperview().offset(11)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        weekDayLabel.textAlignment = .center

        addWithConstraints(view: dayNumberLabel) {
            $0.bottom.equalToSuperview().offset(-9)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        dayNumberLabel.textAlignment = .center

        snp.makeConstraints {
            $0.width.equalTo(62)
            $0.height.equalTo(72)
        }

        addGestureRecognizer(tapDetector)
    }

    @objc func tapped() {
        delegate?.dateSelected(date)
    }
}
