import UIKit

class HostCalendarUpdateLayout: Layout {
    lazy var topBar = TopBar(mode: .host, title: "Review your sessions", customTopView: nil, delegate: self)

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

        rangeBlockView.isHidden = true
        scrollableArea.addWithConstraints(view: rangeBlockView) {
            $0.below(calendarContainer, padding: 30)
            $0.centerX.equalToSuperview()
        }

        startTimeLabel.textAlignment = .right
        startTimeLabel.isHidden = true
        scrollableArea.addWithConstraints(view: startTimeLabel) {
            $0.width.equalTo(50)
            $0.centerY.equalTo(rangeBlockView.snp.centerY).offset(-6)
            $0.trailing.equalTo(rangeBlockView.snp.leading).offset(-5)
        }

        endTimeLabel.textAlignment = .right
        endTimeLabel.isHidden = true
        scrollableArea.addWithConstraints(view: endTimeLabel) {
            $0.width.equalTo(50)
            $0.centerY.equalTo(rangeBlockView.snp.centerY).offset(12)
            $0.trailing.equalTo(rangeBlockView.snp.leading).offset(-5)
        }

        addButton.isHidden = true
        scrollableArea.addWithConstraints(view: addButton) {
            $0.centerY.equalTo(rangeBlockView.snp.centerY)
            $0.leading.equalTo(rangeBlockView.snp.trailing).offset(5)
            $0.width.equalTo(60)
        }

        scrollableArea.addWithConstraints(view: timeSlotSelector) {
            $0.fillHorizontally()
            $0.below(rangeBlockView, padding: 30)
        }

        confirmButton.isHidden = true
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

    private lazy var startTimeLabel = Label(
        style: .xxsmall,
        text: "START TIME:",
        color: Color.mainText,
        lines: 1)

    private lazy var endTimeLabel = Label(
        style: .xxsmall,
        text: "END TIME:",
        color: Color.mainText,
        lines: 1)

    lazy var rangeBlockView = RangeBlockView(
        timeStart: 0,
        timeEnd: 0,
        duration: 0,
        canDelete: false,
        delegate: self)

    lazy var timeSlotSelector = TimeSlotSelector(
        timeSlots: [],
        reservedSessions: [],
        canSelect: false,
        canDeleteIfNotReserved: true,
        selectedTimeSlot: nil,
        delegate: self)

    lazy var addButton = Button(
        style: .greenOutline,
        shape: .roundedRectangle(height: 25),
        title: "ADD",
        image: nil,
        delegate: self)

    lazy var confirmButton = Button(
        style: .green,
        shape: .roundedRectangle(height: 46),
        title: "SAVE",
        image: nil,
        delegate: self)

    lazy var bottomBackButton = ShadyBackButton(delegate: self)

    weak var screen: HostCalendarUpdateScreen?

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

    func show(timeSlots: [Date], reservedSessions: [Int], duration: Int, calendarMonth: Int, calendarYear: Int, selectedDate: Date) {
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

        daySelectedInCalendar(date: selectedDate)
    }
}

extension HostCalendarUpdateLayout: ShadyBackButtonDelegate {
    func backTapped() {
        screen?.goBack()
    }
}

extension HostCalendarUpdateLayout: TopBarDelegate {
    func profileButtonClicked() {
        screen?.openProfile()
    }

    func rightButtonClicked() {
        screen?.openEarnings()
    }
}

extension HostCalendarUpdateLayout: CalendarDelegate {
    func daySelectedInCalendar(date: Date) {
        selectedDayStart = date.dateWithoutTime
        screen?.startDate = selectedDayStart

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let timeSlotStructs = timeSlots.filter {
            $0.dateWithoutTime == selectedDayStart
        }.map { timeSlot in
            screen?.originalExperience.sessions?
                .first(where: { session in
                    session.getStartDateTime()?.timeIntervalSince1970 == timeSlot.timeIntervalSince1970
                }) ??
                SessionResponseResult(
                    id: -1,
                    start_datetime: dateFormatter.string(from: timeSlot),
                    duration: duration,
                    end_datetime: dateFormatter.string(from: timeSlot.addingTimeInterval(TimeInterval(duration * 60)))
                )
        }
        timeSlotSelector.set(
            timeSlots: timeSlotStructs,
            selectedTimeSlot: nil
        )

        let calendar = Calendar(identifier: .gregorian)
        let hours = calendar.component(.hour, from: Date())
        let minutes = calendar.component(.minute, from: Date())
        rangeBlockView.duration = duration
        rangeBlockView.update(timeStart: (hours * 60 + minutes) * 60)
        rangeBlockView.update(timeEnd: ((hours * 60 + minutes + duration) * 60) % 86400)
        rangeBlockView.updateLayout()
        rangeBlockView.isHidden = false
        startTimeLabel.isHidden = false
        endTimeLabel.isHidden = false
        addButton.isHidden = false
        confirmButton.isHidden = false
    }
}

extension HostCalendarUpdateLayout: ButtonDelegate {
    func buttonClicked(button: Button) {
        switch button {
        case confirmButton:
            screen?.confirm()

        case addButton:
            let startSeconds = rangeBlockView.timeStart
            let endSeconds = rangeBlockView.timeEnd
            screen?.addInterval(start: startSeconds, end: endSeconds)

        default:
            break
        }
    }
}

extension HostCalendarUpdateLayout: TimeSlotSelectorDelegate {
    func timeSlotSelected(timeSlot: SessionResponseResult) {
        // Not available here
    }

    func timeSlotDeleted(id: Int) {
        screen?.deleteTimeSlot(id: id)
    }

    func timeSlotDeleted(date: Date) {
        screen?.deleteTimeSlot(date: date)
    }
}

extension HostCalendarUpdateLayout: RangeBlockDelegate {
    func deleteRange(startTime: Int) {
        // Not available here
    }

    func modifyStartRange(initialTime: (Int, Int)) {
        let calendar = Calendar(identifier: .gregorian)
        let hours = initialTime.0 / 3600
        let minutes = (initialTime.0 / 60) % 60
        let components = DateComponents(
            calendar: calendar, timeZone: nil, era: nil,
            year: nil, month: nil, day: nil,
            hour: hours, minute: minutes, second: 0,
            nanosecond: 0, weekday: nil, weekdayOrdinal: nil,
            quarter: nil, weekOfMonth: nil, weekOfYear: nil,
            yearForWeekOfYear: nil)
        let initialDate = calendar.date(from: components)

        let dialog = DatePickerDialog(
            textColor: Color.mainText,
            buttonColor: Color.main,
            font: LabelStyle.normal.font,
            locale: Locale(identifier: "en_US"),
            showCancelButton: true,
            mode: .time)
        dialog.show(
            "Choose start time",
            doneButtonTitle: "Done",
            cancelButtonTitle: "Cancel",
            defaultDate: initialDate ?? Date(),
            minimumDate: nil,
            maximumDate: nil,
            datePickerMode: .time) { [weak self] date in
            guard
                let self = self,
                let date = date
            else { return }
            var seconds = calendar.component(.hour, from: date) * 3600
            seconds += calendar.component(.minute, from: date) * 60
            self.rangeBlockView.update(timeStart: seconds)
            let diff = (self.rangeBlockView.timeEnd + 86400 - self.rangeBlockView.timeStart) % 86400
            if diff < self.duration * 60 {
                self.rangeBlockView.update(timeEnd: (seconds + self.duration * 60) % 86400)
            }
            self.rangeBlockView.updateLayout()
        }
    }

    func modifyEndRange(initialTime: (Int, Int)) {
        let calendar = Calendar(identifier: .gregorian)
        let hours = initialTime.1 / 3600
        let minutes = (initialTime.1 / 60) % 60
        let components = DateComponents(
            calendar: calendar, timeZone: nil, era: nil,
            year: nil, month: nil, day: nil,
            hour: hours, minute: minutes, second: 0,
            nanosecond: 0, weekday: nil, weekdayOrdinal: nil,
            quarter: nil, weekOfMonth: nil, weekOfYear: nil,
            yearForWeekOfYear: nil)
        let initialDate = calendar.date(from: components)

        let dialog = DatePickerDialog(
            textColor: Color.mainText,
            buttonColor: Color.main,
            font: LabelStyle.normal.font,
            locale: Locale(identifier: "en_US"),
            showCancelButton: true,
            mode: .time)
        dialog.show(
            "Choose end time",
            doneButtonTitle: "Done",
            cancelButtonTitle: "Cancel",
            defaultDate: initialDate ?? Date(),
            minimumDate: nil,
            maximumDate: nil,
            datePickerMode: .time) { [weak self] date in
            guard
                let self = self,
                let date = date
            else { return }
            var seconds = calendar.component(.hour, from: date) * 3600
            seconds += calendar.component(.minute, from: date) * 60
            self.rangeBlockView.update(timeEnd: seconds)
            let diff = (self.rangeBlockView.timeEnd + 86400 - self.rangeBlockView.timeStart) % 86400
            if diff < self.duration * 60 {
                self.rangeBlockView.update(timeStart: (seconds + 86400 - self.duration * 60) % 86400)
            }
            self.rangeBlockView.updateLayout()
        }
    }
}
