import UIKit

class HostBookingScreen: ScreenWithInput<HostBookingLayout, HostBookingArguments> {
    var argument: HostBookingArguments!

    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self
    }

    override func input(_ argument: HostBookingArguments) {
        loadViewIfNeeded()

        self.argument = argument

        layout.mondayBlock.isSelected = false
        layout.mondayBlock.set(blocks: [], duration: argument.category.duration * 60)
        layout.tuesdayBlock.isSelected = false
        layout.tuesdayBlock.set(blocks: [], duration: argument.category.duration * 60)
        layout.wednesdayBlock.isSelected = false
        layout.wednesdayBlock.set(blocks: [], duration: argument.category.duration * 60)
        layout.thursdayBlock.isSelected = false
        layout.thursdayBlock.set(blocks: [], duration: argument.category.duration * 60)
        layout.fridayBlock.isSelected = false
        layout.fridayBlock.set(blocks: [], duration: argument.category.duration * 60)
        layout.saturdayBlock.isSelected = false
        layout.saturdayBlock.set(blocks: [], duration: argument.category.duration * 60)
        layout.sundayBlock.isSelected = false
        layout.sundayBlock.set(blocks: [], duration: argument.category.duration * 60)
        layout.serviceLabel.text = "\(argument.subcategory.name) (\(argument.category.duration) MINS)"
    }

    func goNext() {
        let timeSlots: [[Int]?] = [
            layout.mondayBlock.isSelected ? layout.mondayBlock.slots : nil,
            layout.tuesdayBlock.isSelected ? layout.tuesdayBlock.slots : nil,
            layout.wednesdayBlock.isSelected ? layout.wednesdayBlock.slots : nil,
            layout.thursdayBlock.isSelected ? layout.thursdayBlock.slots : nil,
            layout.fridayBlock.isSelected ? layout.fridayBlock.slots : nil,
            layout.saturdayBlock.isSelected ? layout.saturdayBlock.slots : nil,
            layout.sundayBlock.isSelected ? layout.sundayBlock.slots : nil
        ]
        navigator.navigate(
            to: HostCalendarScreen.self,
            argument: HostCalendarArguments(
                category: argument.category,
                subcategory: argument.subcategory,
                description: argument.description,
                languageId: argument.languageId,
                attachedMedias: argument.attachedMedias,
                startDate: layout.startDateSelector.selection.dateWithoutTime,
                endDate: layout.endDateSelector.selection.dateWithoutTime.addingTimeInterval(86400),
                timeSlots: timeSlots,
                hostInfo: argument.hostInfo
            )
        )
    }
}
