import UIKit

class HostCalendarUpdateScreen: ScreenWithInput<HostCalendarUpdateLayout, ExperienceIndexResponseResult> {
    var originalExperience: ExperienceIndexResponseResult!
    var reservedSessions: [Int] = []
    var timeSlotsToAdd: [Date] = []
    var sessionsToDelete: [Int] = []
    var startDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self
    }

    override func input(_ argument: ExperienceIndexResponseResult) {
        originalExperience = argument

        loader.show(text: "Checking reservations")
        Task {
            do {
                let earnings = try await EarningIndexRequest()
                    .performRequest()
                    .result
                    .data
                    ?? []
                reservedSessions = earnings
                    .filter {
                        $0.reservation.experience.id == originalExperience.id
                    }
                    .map {
                        $0.reservation.reservation_session.id
                    }
                await MainActor.run {
                    loader.dismiss()
                    updateLayout()
                }
            } catch {
                await MainActor.run {
                    loader.dismiss()
                    show(error: error.localizedDescription)
                }
            }
        }
    }

    private func updateLayout() {
        var timeSlots = (originalExperience.sessions ?? [])
            .filter { !sessionsToDelete.contains($0.id) }
            .compactMap { $0.getStartDateTime() }

        timeSlots.append(contentsOf: timeSlotsToAdd)

        timeSlots.sort { (e1, e2) in
            e1.timeIntervalSince1970 < e2.timeIntervalSince1970
        }

        guard let subcategory = Cat.findSubcategory(id: originalExperience.category_id),
              let category = Cat.list.first(where: { $0.id == subcategory.category_id })
        else {
            return
        }

        if startDate == nil {
            startDate = timeSlots.first ?? Date()
        }

        let calendar = Calendar(identifier: .gregorian)

        layout.show(
            timeSlots: timeSlots,
            reservedSessions: reservedSessions,
            duration: category.duration,
            calendarMonth: calendar.component(.month, from: startDate!),
            calendarYear: calendar.component(.year, from: startDate!),
            selectedDate: startDate!
        )
    }

    func deleteTimeSlot(id: Int) {
        sessionsToDelete.append(id)
        updateLayout()
    }

    func deleteTimeSlot(date: Date) {
        timeSlotsToAdd.removeAll(where: { $0.timeIntervalSince1970 == date.timeIntervalSince1970 } )
        updateLayout()
    }

    func confirm() {
        loader.show(text: "Updating your sessions")
        Task {
            do {
                // Delete old sessions
                if !sessionsToDelete.isEmpty {
                    _ = try await SessionDeleteMultipleRequest(sessionIds: sessionsToDelete)
                        .performRequest()
                }

                // Create new sessions
                if !timeSlotsToAdd.isEmpty {
                    _ = try await SessionCreateRequest(
                        experienceId: originalExperience.id,
                        startDateTime: timeSlotsToAdd)
                        .performRequest()
                }

                await MainActor.run {
                    loader.dismiss()
                    if !navigator.pop(to: HostPanelScreen.self) {
                        navigator.popToRoot()
                    }
                }
            } catch {
                await MainActor.run {
                    loader.dismiss()
                    show(error: error.localizedDescription)
                }
            }
        }
    }

    override func goBack() {
        if !navigator.pop(to: HostPanelScreen.self) {
            navigator.popToRoot()
        }
    }

    func addInterval(start: Int, end: Int) {
        guard let date = startDate?.dateWithoutTime,
              let durationMinutes = originalExperience.duration
        else {
            return
        }

        let startCorrected = (86400 + start) % 86400
        var endCorrected = (86400 + end) % 86400
        if endCorrected < startCorrected {
            endCorrected += 86400
        }

        var currentTime = startCorrected
        while currentTime + (durationMinutes * 60) <= endCorrected {
            let sessionStartDate = date.addingTimeInterval(TimeInterval(currentTime))
            if !timeSlotsToAdd.contains(where: { $0.timeIntervalSince1970 == sessionStartDate.timeIntervalSince1970 }) {
                timeSlotsToAdd.append(sessionStartDate)
            }

            currentTime += (durationMinutes * 60)
        }

        updateLayout()
    }
}
