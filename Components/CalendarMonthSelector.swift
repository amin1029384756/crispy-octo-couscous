import SnapKit
import UIKit

protocol CalendarMonthSelectorDelegate: AnyObject {
    func changed(month: Int, year: Int)
}

class CalendarMonthSelector: UIView {
    var month: Int
    var year: Int

    weak var delegate: CalendarMonthSelectorDelegate?

    lazy var prevImageButton = ImageButton(asset: .arrowPrev, delegate: self)

    lazy var monthLabel = Label(style: .normal, text: "", color: Color.calendarMonthName, lines: 1)

    lazy var nextImageButton = ImageButton(asset: .arrowNext, delegate: self)

    init(month: Int, year: Int, delegate: CalendarMonthSelectorDelegate?) {
        self.month = month
        self.year = year
        self.delegate = delegate

        super.init(frame: .zero)

        createLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createLayout() {
        addWithConstraints(view: monthLabel) {
            $0.center.equalToSuperview()
        }

        addWithConstraints(view: prevImageButton) {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(monthLabel.snp.leading).offset(-8)
            $0.width.equalTo(16)
            $0.height.equalTo(16)
        }

        addWithConstraints(view: nextImageButton) {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(monthLabel.snp.trailing).offset(8)
            $0.width.equalTo(16)
            $0.height.equalTo(16)
        }

        snp.makeConstraints {
            $0.height.equalTo(16)
        }

        showDate()
    }

    func set(month: Int, year: Int) {
        self.month = month
        self.year = year

        showDate()
    }

    private func showDate() {
        let calendar = Calendar(identifier: .gregorian)
        let dateComponents = DateComponents(calendar: calendar, year: year, month: month)
        let date = calendar.date(from: dateComponents)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        dateFormatter.locale = Locale(identifier: "en_US")
        monthLabel.text = dateFormatter.string(from: date)
    }
}

extension CalendarMonthSelector: ImageButtonDelegate {
    func imageButtonClicked(imageButton: ImageButton) {
        switch imageButton {
        case prevImageButton:
            month -= 1
            if month <= 0 {
                year -= 1
                month = 12
            }
            showDate()
            delegate?.changed(month: month, year: year)

        case nextImageButton:
            month += 1
            if month > 12 {
                year += 1
                month = 1
            }
            showDate()
            delegate?.changed(month: month, year: year)

        default:
            break
        }
    }
}
