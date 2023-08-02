import SnapKit
import UIKit

protocol TileSlotInSelectorDelegate: AnyObject {
    func timeSlotSelected(timeSlot: SessionResponseResult)
    func timeSlotDelete(timeSlot: SessionResponseResult)
}

class TimeSlotInSelector: UIView {
    var timeSlot: SessionResponseResult
    var isSelected: Bool
    var isReserved: Bool
    var canDelete: Bool
    weak var delegate: TileSlotInSelectorDelegate?

    lazy var tapDetector = UITapGestureRecognizer(target: self, action: #selector(tapped))

    lazy var timeFromLabel = Label(style: .dayNumber, text: "0:00", color: Color.titleText, lines: 1)

    lazy var timeFromAmPmLabel = Label(style: .xsmall, text: "AM", color: Color.titleText, lines: 1)

    lazy var timeToLabel = Label(style: .dayNumber, text: "0:00", color: Color.titleText, lines: 1)

    lazy var timeToAmPmLabel = Label(style: .xsmall, text: "AM", color: Color.titleText, lines: 1)

    lazy var reserved = Label(style: .xsmall, text: "RESERVED", color: Color.titleText, lines: 1)

    lazy var deleteButton = ImageButton(asset: .closeSmallGreen, delegate: self)

    init(timeSlot: SessionResponseResult, isSelected: Bool, isReserved: Bool, canDelete: Bool, delegate: TileSlotInSelectorDelegate?) {
        self.isSelected = isSelected
        self.timeSlot = timeSlot
        self.isReserved = isReserved
        self.canDelete = canDelete
        self.delegate = delegate

        super.init(frame: .zero)

        createLayout()
        show(timeSlot: timeSlot, isSelected: isSelected, isReserved: isReserved, canDelete: canDelete)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createLayout() {
        layer.cornerRadius = 20
        layer.masksToBounds = true
        layer.borderWidth = 1.0
        layer.borderColor = Color.lightBorder.cgColor

        let leftPaddingView = UIView()
        leftPaddingView.backgroundColor = .clear
        addWithConstraints(view: leftPaddingView) {
            $0.centerY.equalToSuperview()
            $0.height.equalTo(1)
            $0.leading.equalToSuperview()
        }

        addWithConstraints(view: timeFromLabel) {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(leftPaddingView.snp.trailing)
        }

        addWithConstraints(view: timeFromAmPmLabel) {
            $0.bottom.equalTo(timeFromLabel.snp.bottom).offset(-2)
            $0.leading.equalTo(timeFromLabel.snp.trailing)
        }

        addWithConstraints(view: timeToLabel) {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(timeFromAmPmLabel.snp.trailing).offset(8)
        }

        addWithConstraints(view: timeToAmPmLabel) {
            $0.bottom.equalTo(timeToLabel.snp.bottom).offset(-2)
            $0.leading.equalTo(timeToLabel.snp.trailing)
        }

        reserved.isHidden = true
        addWithConstraints(view: reserved) {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
        }

        deleteButton.isHidden = true
        addWithConstraints(view: deleteButton) {
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.width.equalTo(32)
            $0.height.equalTo(32)
        }

        let rightPaddingView = UIView()
        rightPaddingView.backgroundColor = .clear
        addWithConstraints(view: rightPaddingView) {
            $0.leading.equalTo(timeToAmPmLabel.snp.trailing)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(1)
            $0.trailing.equalToSuperview()
            $0.width.equalTo(leftPaddingView.snp.width)
        }

        snp.makeConstraints {
            $0.height.equalTo(78)
        }

        addGestureRecognizer(tapDetector)
    }

    func show(timeSlot: SessionResponseResult, isSelected: Bool, isReserved: Bool, canDelete: Bool) {
        self.timeSlot = timeSlot
        self.isSelected = isSelected
        self.isReserved = isReserved
        self.canDelete = canDelete

        reserved.isHidden = !isReserved
        deleteButton.isHidden = !canDelete

        let startTime = timeSlot.getStartDateTime() ?? Date()
        let endTime = timeSlot.getEndDateTime() ?? Date()

        let secondsStart = startTime.secondFromMidnight
        let secondsEnd = endTime.secondFromMidnight
        let fromPair = secondsStart.secondsToStringAmPm
        let toPair = secondsEnd.secondsToStringAmPm

        timeFromLabel.text = fromPair.0
        timeFromAmPmLabel.text = fromPair.1
        timeToLabel.text = "— " + toPair.0
        timeToAmPmLabel.text = toPair.1

        if isSelected {
            backgroundColor = Color.mainDark
            timeFromLabel.textColor = .white
            timeFromAmPmLabel.textColor = .white
            timeToLabel.textColor = .white
            timeToAmPmLabel.textColor = .white
        } else {
            backgroundColor = .white
            timeFromLabel.textColor = Color.mainText
            timeFromAmPmLabel.textColor = Color.mainText
            timeToLabel.textColor = Color.mainText
            timeToAmPmLabel.textColor = Color.mainText
        }
    }

    @objc func tapped() {
        delegate?.timeSlotSelected(timeSlot: timeSlot)
    }
}

extension TimeSlotInSelector: ImageButtonDelegate {
    func imageButtonClicked(imageButton: ImageButton) {
        if imageButton == deleteButton {
            delegate?.timeSlotDelete(timeSlot: timeSlot)
        }
    }
}
