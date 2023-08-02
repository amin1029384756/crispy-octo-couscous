import UIKit

class HostCalendarScreen: ScreenWithInput<HostCalendarLayout, HostCalendarArguments> {
    var timeSlots: [Date] = []

    var argument: HostCalendarArguments!

    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self
    }

    func confirm() {
        navigator.navigate(
            to: HostAdReviewScreen.self,
            argument: argument)
    }

    override func input(_ argument: HostCalendarArguments) {
        loadViewIfNeeded()

        self.argument = argument

        let startDate = argument.startDate.dateWithoutTime

        let calendar = Calendar(identifier: .gregorian)

        timeSlots = argument.generateSessionDates()

        layout.show(
            timeSlots: timeSlots,
            duration: argument.category.duration,
            calendarMonth: calendar.component(.month, from: startDate),
            calendarYear: calendar.component(.year, from: startDate),
            selectedDate: startDate
        )
    }
}
