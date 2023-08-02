import UIKit

class HostCalendarLayout: Layout {
    lazy var topBar = TopBar(mode: .host, title: "Become a Host - Booking", customTopView: nil, delegate: self)

    lazy var mainScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        scrollView.keyboardDismissMode = .onDrag
        scrollView.addWithConstraints(view: mainScrollableArea) {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }
        return scrollView
    }()

    lazy var mainScrollableArea: UIView = {
        let scrollableArea = UIView()

        scrollableArea.addWithConstraints(view: calendarContainer) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(40)
        }

        scrollableArea.addWithConstraints(view: timeSlotSelector) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(calendarContainer.snp.bottom).offset(30)
        }

        scrollableArea.addWithConstraints(view: confirmButton) {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(timeSlotSelector.snp.bottom).offset(16)
            $0.width.equalTo(150)
        }

        scrollableArea.subviews.last?.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-32)
        }

        return scrollableArea
    }()

    lazy var calendarContainer = UIView()

    var calendarView: CalendarView?

    lazy var timeSlotSelector = TimeSlotSelector(
        timeSlots: [],
        reservedSessions: [],
        canSelect: false,
        canDeleteIfNotReserved: false,
        selectedTimeSlot: nil,
        delegate: nil)

    lazy var confirmButton = Button(
        style: .green,
        shape: .roundedRectangle(height: 46),
        title: "CONFIRM",
        image: nil,
        delegate: self)

    lazy var bottomBackButton = ShadyBackButton(delegate: self)

    weak var screen: HostCalendarScreen?

    var timeSlots: [Date] = []
    var selectedDayStart = Date().dateWithoutTime

    var duration = 0

    override func createLayout() {
        addWithConstraints(view: mainScrollView) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        addWithConstraints(view: topBar) {
            $0.top.equalTo(layoutMarginsGuide.snp.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(mainScrollView.snp.top)
        }

        addWithConstraints(view: bottomBackButton) {
            $0.leading.equalToSuperview().offset(30)
            $0.bottom.equalToSuperview().offset(28)
        }
    }

    func show(timeSlots: [Date], duration: Int, calendarMonth: Int, calendarYear: Int, selectedDate: Date) {
        selectedDayStart = selectedDate.dateWithoutTime
        self.duration = duration
        self.timeSlots = timeSlots

        let oldCalendar = calendarContainer.subviews
        oldCalendar.forEach {
            $0.removeFromSuperview()
        }

        calendarView = CalendarView(
            month: calendarMonth,
            year: calendarYear,
            selectedDate: selectedDayStart,
            datesWithSlots: timeSlots,
            delegate: self
        )

        calendarContainer.addWithConstraints(view: calendarView!) {
            $0.edges.equalToSuperview()
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        timeSlotSelector.set(
            timeSlots: timeSlots.filter {
                        $0.dateWithoutTime == selectedDayStart
                    }.map {
                        SessionResponseResult(
                            id: -1,
                            start_datetime: dateFormatter.string(from: $0),
                            duration: duration,
                            end_datetime: dateFormatter.string(from: $0.addingTimeInterval(TimeInterval(duration * 60)))
                        )
                    },
            selectedTimeSlot: nil
        )
    }
}

extension HostCalendarLayout: ShadyBackButtonDelegate {
    func backTapped() {
        screen?.goBack()
    }
}

extension HostCalendarLayout: TopBarDelegate {
    func profileButtonClicked() {
        screen?.openProfile()
    }

    func rightButtonClicked() {
        screen?.openEarnings()
    }
}

extension HostCalendarLayout: CalendarDelegate {
    func daySelectedInCalendar(date: Date) {
        selectedDayStart = date.dateWithoutTime

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let dayTimeSlots = timeSlots.filter {
                    $0.dateWithoutTime == selectedDayStart
                }.map {
                    SessionResponseResult(
                        id: -1,
                        start_datetime: dateFormatter.string(from: $0),
                        duration: duration,
                        end_datetime: dateFormatter.string(from: $0.addingTimeInterval(TimeInterval(duration * 60)))
                    )
                }
        timeSlotSelector.set(
            timeSlots: dayTimeSlots,
            selectedTimeSlot: nil
        )
    }
}

extension HostCalendarLayout: ButtonDelegate {
    func buttonClicked(button: Button) {
        switch button {
        case confirmButton:
            screen?.confirm()

        default:
            break
        }
    }
}
