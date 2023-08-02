import Foundation

struct HostCalendarArguments {
    var category: CategoryResponseResult
    var subcategory: SubcategoryResponseResult
    var description: String
    var languageId: Int
    var attachedMedias: [FileWithMetadata]
    var startDate: Date
    var endDate: Date
    var timeSlots: [[Int]?]
    var hostInfo: HostInfo

    func generateSessionDates() -> [Date] {
        var result = [Date]()

        var date = startDate
        let calendar = Calendar(identifier: .gregorian)
        while endDate.timeIntervalSince(date) > 0 {
            let weekday = calendar.component(.weekday, from: date)
            var timeIntervals: [Int] = []
            if weekday == 1 {
                // Sunday
                if timeSlots.count > 6 {
                    timeIntervals = timeSlots[6] ?? []
                }
            } else if weekday > 1,
                      weekday <= 7 {
                // Monday to Saturday
                if timeSlots.count > weekday - 2 {
                    timeIntervals = timeSlots[weekday - 2] ?? []
                }
            }
            if !timeIntervals.isEmpty {
                for timeInterval in timeIntervals {
                    var timeSlot = Date(timeIntervalSince1970: date.timeIntervalSince1970)
                    timeSlot = timeSlot.addingTimeInterval(TimeInterval(timeInterval))
                    result.append(timeSlot)
                }
            }
            date = date.addingTimeInterval(86400)
        }

        return result
    }
}
