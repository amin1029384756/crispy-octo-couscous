import SnapKit
import UIKit

class CalendarWeekDays: UIView {
    lazy var mon = Label(
        style: .calendarWeekday,
        text: "Mon",
        color: Color.calendarDayName,
        lines: 1)

    lazy var tue = Label(
        style: .calendarWeekday,
        text: "Tue",
        color: Color.calendarDayName,
        lines: 1)

    lazy var wed = Label(
        style: .calendarWeekday,
        text: "Wed",
        color: Color.calendarDayName,
        lines: 1)

    lazy var thu = Label(
        style: .calendarWeekday,
        text: "Thu",
        color: Color.calendarDayName,
        lines: 1)

    lazy var fri = Label(
        style: .calendarWeekday,
        text: "Fri",
        color: Color.calendarDayName,
        lines: 1)

    lazy var sat = Label(
        style: .calendarWeekday,
        text: "Sat",
        color: Color.calendarDayName,
        lines: 1)

    lazy var sun = Label(
        style: .calendarWeekday,
        text: "Sun",
        color: Color.calendarDayName,
        lines: 1)

    init() {
        super.init(frame: .zero)

        createLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createLayout() {
        addWithConstraints(view: mon) {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        addWithConstraints(view: tue) {
            $0.leading.equalTo(mon.snp.trailing)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(mon.snp.width)
        }

        addWithConstraints(view: wed) {
            $0.leading.equalTo(tue.snp.trailing)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(mon.snp.width)
        }

        addWithConstraints(view: thu) {
            $0.leading.equalTo(wed.snp.trailing)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(mon.snp.width)
        }

        addWithConstraints(view: fri) {
            $0.leading.equalTo(thu.snp.trailing)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(mon.snp.width)
        }

        addWithConstraints(view: sat) {
            $0.leading.equalTo(fri.snp.trailing)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(mon.snp.width)
        }

        addWithConstraints(view: sun) {
            $0.leading.equalTo(sat.snp.trailing)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(mon.snp.width)
            $0.trailing.equalToSuperview()
        }

        snp.makeConstraints {
            $0.height.equalTo(16)
        }

        [mon, tue, wed, thu, fri, sat, sun].forEach {
            $0.textAlignment = .center
        }
    }
}
