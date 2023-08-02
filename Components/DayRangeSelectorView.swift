import UIKit

class DayRangeSelectorView: UIView {
    var dayName: String
    var blocks: [(Int, Int)] = []
    var slots: [Int] {
        var calculatedSlots = [Int]()
        for block in blocks {
            var timeStart = block.0
            while timeStart + duration <= block.1 {
                calculatedSlots.append(timeStart)
                timeStart += duration
            }
        }
        return calculatedSlots
    }
    var duration: Int = 1800

    var isSelected = false {
        didSet {
            if isSelected {
                weekDayTitleLabel.backgroundColor = Color.main
                weekDayTitleLabel.textColor = .white
                weekDayTitleLabel.layer.cornerRadius = 10
                weekDayTitleLabel.layer.masksToBounds = true
                blocksScrollView.isHidden = false
                startTimeLabel.isHidden = false
                endTimeLabel.isHidden = false
            } else {
                weekDayTitleLabel.backgroundColor = .white
                weekDayTitleLabel.textColor = Color.main
                weekDayTitleLabel.layer.cornerRadius = 10
                weekDayTitleLabel.layer.masksToBounds = false
                blocksScrollView.isHidden = true
                startTimeLabel.isHidden = true
                endTimeLabel.isHidden = true
            }
        }
    }

    private lazy var weekDayTitleLabel = Label(
        style: .xsmall,
        text: dayName,
        color: Color.main,
        lines: 1)

    private lazy var dayTitleTapDetector = UITapGestureRecognizer(
        target: self,
        action: #selector(toggleDay))

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

    private lazy var separatorView = Image(asset: .separator)

    private lazy var blocksView = UIView()

    private lazy var blocksScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        scrollView.addWithConstraints(view: blocksView) {
            $0.edges.equalToSuperview()
            $0.height.equalTo(scrollView.snp.height)
        }

        return scrollView
    }()

    init(dayName: String) {
        self.dayName = dayName

        super.init(frame: .zero)

        createLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createLayout() {
        weekDayTitleLabel.layer.borderWidth = 1
        weekDayTitleLabel.layer.borderColor = Color.main.cgColor
        weekDayTitleLabel.layer.cornerRadius = 10
        weekDayTitleLabel.textAlignment = .center
        weekDayTitleLabel.isUserInteractionEnabled = true
        weekDayTitleLabel.addGestureRecognizer(dayTitleTapDetector)
        addWithConstraints(view: weekDayTitleLabel) {
            $0.centerY.equalToSuperview()
            $0.width.equalTo(64)
            $0.leading.equalToSuperview().offset(36)
            $0.height.equalTo(20)
        }

        startTimeLabel.textAlignment = .right
        addWithConstraints(view: startTimeLabel) {
            $0.width.equalTo(50)
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalTo(weekDayTitleLabel.snp.trailing).offset(5)
        }

        endTimeLabel.textAlignment = .right
        addWithConstraints(view: endTimeLabel) {
            $0.width.equalTo(50)
            $0.top.equalToSuperview().offset(26)
            $0.leading.equalTo(weekDayTitleLabel.snp.trailing).offset(5)
        }

        addWithConstraints(view: separatorView) {
            $0.bottom.equalToSuperview()
            $0.leading.equalTo(weekDayTitleLabel.snp.trailing)
            $0.width.equalTo(86)
            $0.height.equalTo(1)
        }

        addWithConstraints(view: blocksScrollView) {
            $0.leading.equalTo(startTimeLabel.snp.trailing).offset(8)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(34)
            $0.trailing.equalToSuperview()
        }
    }

    // In seconds
    func set(blocks: [(Int, Int)], duration: Int) {
        self.blocks = blocks
        self.duration = duration

        createBlocks()
    }

    func createBlocks() {
        let oldSubviews = blocksView.subviews
        oldSubviews.forEach {
            $0.removeFromSuperview()
        }

        var previousView: UIView?
        for block in blocks {
            let rangeBlockView = RangeBlockView(
                timeStart: block.0,
                timeEnd: block.1,
                duration: duration,
                canDelete: true,
                delegate: self)
            blocksView.addWithConstraints(view: rangeBlockView) {
                if let previousView = previousView {
                    $0.leading.equalTo(previousView.snp.trailing).offset(8)
                } else {
                    $0.leading.equalToSuperview()
                }
                $0.centerY.equalToSuperview()
            }

            let separatorView = UIView()
            separatorView.backgroundColor = .lightGray.withAlphaComponent(0.3)
            blocksView.addWithConstraints(view: separatorView) {
                $0.leading.equalTo(rangeBlockView.snp.trailing).offset(8)
                $0.centerY.equalToSuperview()
                $0.height.equalTo(23)
                $0.width.equalTo(1)
            }

            previousView = separatorView
        }

        let newRangeView = NewRangeView(delegate: self)
        blocksView.addWithConstraints(view: newRangeView) {
            if let previousView = previousView {
                $0.leading.equalTo(previousView.snp.trailing).offset(8)
            } else {
                $0.leading.equalToSuperview()
            }
            $0.centerY.equalToSuperview().offset(3)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }

    @objc func toggleDay() {
        isSelected = !isSelected
    }
}

extension DayRangeSelectorView: RangeBlockDelegate {
    func deleteRange(startTime: Int) {
        blocks = blocks.filter {
            $0.0 != startTime
        }
        set(blocks: blocks, duration: duration)
    }

    func modifyStartRange(initialTime: (Int, Int)) {
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
            defaultDate: Date(),
            minimumDate: nil,
            maximumDate: nil,
            datePickerMode: .time) { [weak self] date in
            guard
                let self = self,
                let date = date
            else { return }
            self.blocks = self.blocks.filter {
                $0 != initialTime
            }
            let calendar = Calendar(identifier: .gregorian)
            var seconds = calendar.component(.hour, from: date) * 3600
            seconds += calendar.component(.minute, from: date) * 60
            self.blocks.append((seconds, initialTime.1))
            self.blocks.sort { b1, b2 in
                b1.0 < b2.0
            }
            self.set(blocks: self.blocks, duration: self.duration)
        }
    }

    func modifyEndRange(initialTime: (Int, Int)) {
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
            defaultDate: Date(),
            minimumDate: nil,
            maximumDate: nil,
            datePickerMode: .time) { [weak self] date in
            guard
                let self = self,
                let date = date
            else { return }
            self.blocks = self.blocks.filter {
                $0 != initialTime
            }
            let calendar = Calendar(identifier: .gregorian)
            var seconds = calendar.component(.hour, from: date) * 3600
            seconds += calendar.component(.minute, from: date) * 60
            self.blocks.append((initialTime.0, seconds))
            self.blocks.sort { b1, b2 in
                b1.0 < b2.0
            }
            self.set(blocks: self.blocks, duration: self.duration)
        }
    }
}

extension DayRangeSelectorView: NewRangeViewDelegate {
    func addRange() {
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
            defaultDate: Date(),
            minimumDate: nil,
            maximumDate: nil,
            datePickerMode: .time) { [weak self] date in
            guard
                let self = self,
                let date = date
                else { return }
            let calendar = Calendar(identifier: .gregorian)
            var seconds = calendar.component(.hour, from: date) * 3600
            seconds += calendar.component(.minute, from: date) * 60
            self.blocks.append((seconds, seconds + self.duration))
            self.blocks.sort { b1, b2 in
                b1.0 < b2.0
            }
            self.set(blocks: self.blocks, duration: self.duration)
        }
    }
}
