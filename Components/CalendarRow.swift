import SnapKit
import UIKit

class CalendarRow: UIView {
    var dates: [Date?]
    var dateSelected: Date
    var datesWithSlots: [Date]
    weak var delegate: CalendarDelegate?

    init(dateStart: Date, dateSelected: Date, datesWithSlots: [Date], isFirstLine: Bool, delegate: CalendarDelegate?) {
        self.dates = []
        self.dateSelected = dateSelected
        self.datesWithSlots = datesWithSlots
        self.delegate = delegate

        super.init(frame: .zero)

        let calendar = Calendar(identifier: .gregorian)
        var currentDate = dateStart
        var targetMonth = calendar.component(.month, from: dateStart)
        if isFirstLine {
            targetMonth = (targetMonth + 1) % 12
        }
        for _ in 0..<7 {
            let month = calendar.component(.month, from: currentDate)
            if month == targetMonth {
                dates.append(currentDate)
            } else {
                dates.append(nil)
            }
            currentDate = currentDate.addingTimeInterval(86400)
        }

        createLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createLayout() {
        var previousView: UIView?

        for date in dates {
            if let date = date {
                let newView = CalendarDay(
                    date: date,
                    hasAvailableSlots: datesWithSlots.contains(where: { $0.dateWithoutTime == date.dateWithoutTime }),
                    isSelected: date == dateSelected, delegate: delegate)
                addWithConstraints(view: newView) {
                    if let previousView = previousView {
                        $0.leading.equalTo(previousView.snp.trailing)
                        $0.width.equalTo(previousView.snp.width)
                    } else {
                        $0.leading.equalToSuperview()
                    }
                    $0.centerY.equalToSuperview()
                }
                previousView = newView
            } else {
                let newView = UIView()
                addWithConstraints(view: newView) {
                    if let previousView = previousView {
                        $0.leading.equalTo(previousView.snp.trailing)
                        $0.width.equalTo(previousView.snp.width)
                    } else {
                        $0.leading.equalToSuperview()
                    }
                    $0.centerY.equalToSuperview()
                }
                previousView = newView
            }
        }

        previousView?.snp.makeConstraints {
            $0.trailing.equalToSuperview()
        }

        snp.makeConstraints {
            $0.height.equalTo(35)
        }
    }
}
