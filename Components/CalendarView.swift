import SnapKit
import UIKit

class CalendarView: UIView {
    let monthSelector: CalendarMonthSelector

    lazy var weekDays = CalendarWeekDays()

    var rows = [CalendarRow]()

    var month: Int
    var year: Int
    var selectedDate: Date
    var datesWithSlots: [Date]

    weak var delegate: CalendarDelegate?

    init(month: Int, year: Int, selectedDate: Date, datesWithSlots: [Date], delegate: CalendarDelegate?) {
        self.selectedDate = selectedDate
        self.month = month
        self.year = year
        self.datesWithSlots = datesWithSlots
        self.delegate = delegate

        monthSelector = CalendarMonthSelector(month: month, year: year, delegate: nil)

        super.init(frame: .zero)

        monthSelector.delegate = self

        createLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createLayout() {
        addWithConstraints(view: monthSelector) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
        }

        addWithConstraints(view: weekDays) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(monthSelector.snp.bottom).offset(28)
        }

        createCalendarRows()
    }

    private func createCalendarRows() {
        var previousView: UIView = weekDays

        let calendar = Calendar(identifier: .gregorian)
        let dateComponents = DateComponents(calendar: calendar, year: year, month: month, day: 1)
        var date = dateComponents.date!
        var weekday = calendar.dateComponents([.weekday], from: date).weekday!
        var weekStartsFromMonday = true
        // weekday should be Monday - it's 2
        while weekday != 2 {
            date = date.addingTimeInterval(-86400)
            weekStartsFromMonday = false
            weekday = calendar.dateComponents([.weekday], from: date).weekday!
        }

        var isFirstLine = !weekStartsFromMonday

        while true {
            let rowLineComponents = calendar.dateComponents([.month, .year], from: date)
            if rowLineComponents.year! > year ||
                (rowLineComponents.year! == year && rowLineComponents.month! > month) {
                // Month is over. Finishing
                previousView.snp.makeConstraints {
                    $0.bottom.equalToSuperview()
                }
                break
            }

            let row = CalendarRow(
                dateStart: date,
                dateSelected: selectedDate,
                datesWithSlots: datesWithSlots,
                isFirstLine: isFirstLine,
                delegate: self)
            rows.append(row)
            addWithConstraints(view: row) {
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
                $0.top.equalTo(previousView.snp.bottom)
            }

            isFirstLine = false
            previousView = row
            date = date.addingTimeInterval(86400 * 7)
        }
    }

    fileprivate func recreateRows() {
        rows.forEach {
            $0.removeFromSuperview()
        }
        rows.removeAll()

        createCalendarRows()
    }
}

extension CalendarView: CalendarMonthSelectorDelegate {
    func changed(month: Int, year: Int) {
        self.month = month
        self.year = year

        recreateRows()
    }
}

extension CalendarView: CalendarDelegate {
    func daySelectedInCalendar(date: Date) {
        selectedDate = date

        recreateRows()

        delegate?.daySelectedInCalendar(date: date)
    }
}
