import UIKit

class HostBookingLayout: Layout {
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
        scrollableArea.backgroundColor = .clear

        titleLabel.textAlignment = .center
        scrollableArea.addWithConstraints(view: titleLabel) {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(22)
        }

        scrollableArea.addWithConstraints(view: serviceLabel) {
            $0.centerX.equalToSuperview().offset(8)
            $0.top.equalTo(titleLabel.snp.bottom).offset(22)
        }

        scrollableArea.addWithConstraints(view: serviceIcon) {
            $0.trailing.equalTo(serviceLabel.snp.leading).offset(-4)
            $0.centerY.equalTo(serviceLabel.snp.centerY)
            $0.width.equalTo(14)
            $0.height.equalTo(12)
        }

        scrollableArea.addWithConstraints(view: dateLine) {
            $0.width.equalTo(13)
            $0.height.equalTo(1)
            $0.top.equalTo(serviceLabel.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
        }

        scrollableArea.addWithConstraints(view: startDateSelector) {
            $0.centerY.equalTo(dateLine)
            $0.trailing.equalTo(dateLine.snp.leading).offset(-24)
        }

        scrollableArea.addWithConstraints(view: endDateLabel) {
            $0.centerY.equalTo(dateLine)
            $0.leading.equalTo(dateLine.snp.trailing).offset(21)
        }

        scrollableArea.addWithConstraints(view: startDateLabel) {
            $0.centerY.equalTo(dateLine)
            $0.trailing.equalTo(startDateSelector.snp.leading).offset(-13)
        }

        scrollableArea.addWithConstraints(view: endDateSelector) {
            $0.centerY.equalTo(dateLine)
            $0.leading.equalTo(endDateLabel.snp.trailing).offset(13)
        }

        scrollableArea.addWithConstraints(view: separator1) {
            $0.leading.equalToSuperview().offset(60)
            $0.trailing.equalToSuperview().offset(60)
            $0.height.equalTo(1)
            $0.top.equalTo(dateLine.snp.bottom).offset(26)
        }

        scrollableArea.addWithConstraints(view: selectBlocksOfTimeLabel) {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(separator1.snp.bottom).offset(16)
        }

        scrollableArea.addWithConstraints(view: mondayBlock) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(selectBlocksOfTimeLabel.snp.bottom).offset(48)
        }

        scrollableArea.addWithConstraints(view: tuesdayBlock) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(mondayBlock.snp.bottom).offset(12)
        }

        scrollableArea.addWithConstraints(view: wednesdayBlock) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(tuesdayBlock.snp.bottom).offset(12)
        }

        scrollableArea.addWithConstraints(view: thursdayBlock) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(wednesdayBlock.snp.bottom).offset(12)
        }

        scrollableArea.addWithConstraints(view: fridayBlock) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(thursdayBlock.snp.bottom).offset(12)
        }

        scrollableArea.addWithConstraints(view: saturdayBlock) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(fridayBlock.snp.bottom).offset(12)
        }

        scrollableArea.addWithConstraints(view: sundayBlock) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(saturdayBlock.snp.bottom).offset(12)
        }

        scrollableArea.addWithConstraints(view: reviewCalendarButton) {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(sundayBlock.snp.bottom).offset(16)
            $0.width.equalTo(210)
        }

        scrollableArea.subviews.last?.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-32)
        }

        return scrollableArea
    }()

    lazy var titleLabel = Label(
        style: .regular,
        text: "LET'S BUILD YOUR CALENDAR",
        color: Color.mainText,
        lines: 1)

    lazy var serviceIcon = UIImageView()

    lazy var serviceLabel = Label(
        style: .small,
        text: "MORNING CHECK-IN (20 MINS)",
        color: Color.mainText,
        lines: 1)

    lazy var startDateLabel = Label(
        style: .xsmall,
        text: "START DATE",
        color: Color.mainText,
        lines: 1)

    lazy var startDateSelector = ComboBoxDate(
        minDate: Date(),
        maxDate: nil,
        selection: Date(),
        delegate: self)

    lazy var dateLine: UIView = {
        let view = UIView()
        view.backgroundColor = Color.mainText
        return view
    }()

    lazy var endDateLabel = Label(
        style: .xsmall,
        text: "END DATE",
        color: Color.mainText,
        lines: 1)

    lazy var endDateSelector = ComboBoxDate(
        minDate: Date(),
        maxDate: nil,
        selection: Date(),
        delegate: self)

    lazy var separator1: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageAsset.separator.image
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    lazy var selectBlocksOfTimeLabel = Label(
        style: .xsmall,
        text: "SELECT YOUR AVAILABLE BLOCKS OF TIME",
        color: Color.mainText,
        lines: 1)

    lazy var mondayBlock = DayRangeSelectorView(dayName: "MONDAYS")

    lazy var tuesdayBlock = DayRangeSelectorView(dayName: "TUESDAYS")

    lazy var wednesdayBlock = DayRangeSelectorView(dayName: "WEDNESDAYS")

    lazy var thursdayBlock = DayRangeSelectorView(dayName: "THURSDAYS")

    lazy var fridayBlock = DayRangeSelectorView(dayName: "FRIDAYS")

    lazy var saturdayBlock = DayRangeSelectorView(dayName: "SATURDAYS")

    lazy var sundayBlock = DayRangeSelectorView(dayName: "SUNDAYS")

    lazy var reviewCalendarButton = Button(
        style: .green,
        shape: .roundedRectangle(height: 46),
        title: "REVIEW THE CALENDAR",
        image: nil,
        delegate: self)

    lazy var bottomBackButton = ShadyBackButton(delegate: self)

    weak var screen: HostBookingScreen?

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
}

extension HostBookingLayout: ShadyBackButtonDelegate {
    func backTapped() {
        screen?.goBack()
    }
}

extension HostBookingLayout: TopBarDelegate {
    func profileButtonClicked() {
        screen?.openProfile()
    }

    func rightButtonClicked() {
        screen?.openEarnings()
    }
}

extension HostBookingLayout: ComboBoxDateDelegate {
    func comboBoxDateChanged(comboBox: ComboBoxDate, selection: Date) {
    }
}

extension HostBookingLayout: ButtonDelegate {
    func buttonClicked(button: Button) {
        switch button {
        case reviewCalendarButton:
            screen?.goNext()

        default:
            break
        }
    }
}
