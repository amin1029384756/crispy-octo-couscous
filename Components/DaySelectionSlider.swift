import SnapKit
import UIKit

protocol DaySelectionSliderDelegate: AnyObject {
    func dateSelected(_ date: Date)
}

class DaySelectionSlider: UIScrollView {
    var days: [Date]
    var selectedDate: Date
    weak var daySelectionDelegate: DaySelectionSliderDelegate?

    init(days: [Date], selectedDate: Date, delegate: DaySelectionSliderDelegate?) {
        self.days = days
        self.selectedDate = selectedDate
        self.daySelectionDelegate = delegate

        super.init(frame: .zero)

        createLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createLayout() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        alwaysBounceVertical = false

        createDays()

        snp.makeConstraints {
            $0.height.equalTo(72)
        }
    }

    private func createDays() {
        var previousView: UIView?

        for day in days {
            let dayView = DayInSlider(date: day, isSelected: day == selectedDate, delegate: self)
            addWithConstraints(view: dayView) {
                if let previousView = previousView {
                    $0.leading.equalTo(previousView.snp.trailing).offset(12)
                } else {
                    $0.leading.equalToSuperview().offset(24)
                }
                $0.centerY.equalToSuperview()
            }
            previousView = dayView
        }

        previousView?.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-24)
        }
    }

    func set(days: [Date], selectedDate: Date) {
        self.days = days
        self.selectedDate = selectedDate

        let oldViews = subviews
        oldViews.forEach {
            $0.removeFromSuperview()
        }

        createDays()
    }
}

extension DaySelectionSlider: DayInSliderDelegate {
    func dateSelected(_ date: Date) {
        self.selectedDate = date
        for subview in subviews {
            if let dayView = subview as? DayInSlider {
                dayView.setSelected(dayView.date == selectedDate)
            }
        }
        daySelectionDelegate?.dateSelected(date)
    }
}
