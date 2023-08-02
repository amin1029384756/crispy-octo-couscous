import SnapKit
import UIKit

protocol TimeSlotSelectorDelegate: AnyObject {
    func timeSlotSelected(timeSlot: SessionResponseResult)
    func timeSlotDeleted(id: Int)
    func timeSlotDeleted(date: Date)
}

class TimeSlotSelector: UIView {
    var timeSlots: [SessionResponseResult]
    var reservedSessions: [Int]
    var selectedTimeSlot: Int?
    var canSelect: Bool
    var canDeleteIfNotReserved: Bool
    weak var delegate: TimeSlotSelectorDelegate?

    init(timeSlots: [SessionResponseResult],
         reservedSessions: [Int],
         canSelect: Bool,
         canDeleteIfNotReserved: Bool,
         selectedTimeSlot: Int?,
         delegate: TimeSlotSelectorDelegate?
    ) {
        self.timeSlots = timeSlots
        self.reservedSessions = reservedSessions
        self.canSelect = canSelect
        self.canDeleteIfNotReserved = canDeleteIfNotReserved
        self.delegate = delegate
        self.selectedTimeSlot = selectedTimeSlot

        super.init(frame: .zero)

        createLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createLayout() {
        var previousView: UIView?

        for timeSlot in timeSlots {
            let isReserved = reservedSessions.contains(where: { $0 == timeSlot.id })
            let timeSlotView = TimeSlotInSelector(
                timeSlot: timeSlot,
                isSelected: selectedTimeSlot == timeSlot.id,
                isReserved: isReserved,
                canDelete: canDeleteIfNotReserved && !isReserved,
                delegate: self)

            addWithConstraints(view: timeSlotView) {
                if let previousView = previousView {
                    $0.top.equalTo(previousView.snp.bottom).offset(20)
                } else {
                    $0.top.equalToSuperview()
                }
                $0.leading.equalToSuperview().offset(24)
                $0.trailing.equalToSuperview().offset(-36)
            }

            previousView = timeSlotView
        }

        previousView?.snp.makeConstraints {
            $0.bottom.equalToSuperview()
        }
    }

    func set(timeSlots: [SessionResponseResult],
             selectedTimeSlot: Int?) {
        self.timeSlots = timeSlots
        self.selectedTimeSlot = selectedTimeSlot

        let oldViews = subviews
        oldViews.forEach {
            $0.removeFromSuperview()
        }

        createLayout()
    }
}

extension TimeSlotSelector: TileSlotInSelectorDelegate {
    func timeSlotDelete(timeSlot: SessionResponseResult) {
        if timeSlot.id >= 0 {
            delegate?.timeSlotDeleted(id: timeSlot.id)
        } else if let dateTime = timeSlot.getStartDateTime() {
            delegate?.timeSlotDeleted(date: dateTime)
        }
    }

    func timeSlotSelected(timeSlot: SessionResponseResult) {
        if let delegate = delegate, canSelect {
            set(timeSlots: timeSlots, selectedTimeSlot: timeSlot.id)
            delegate.timeSlotSelected(timeSlot: timeSlot)
        }
    }
}
