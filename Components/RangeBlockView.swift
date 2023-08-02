import UIKit

protocol RangeBlockDelegate: AnyObject {
    func deleteRange(startTime: Int)
    func modifyStartRange(initialTime: (Int, Int))
    func modifyEndRange(initialTime: (Int, Int))
}

class RangeBlockView: UIView {
    weak var delegate: RangeBlockDelegate?

    private let calendar = Calendar(identifier: .gregorian)

    var timeStart: Int
    var duration: Int
    var timeEnd: Int
    var canDelete: Bool

    var timeStartAsDate: Date {
        let hour = timeStart / 3600
        let minute = (timeStart / 60) % 60
        let second = timeStart % 60
        return calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: second,
            of: Date(),
            direction: .forward)!
    }
    var timeEndAsDate: Date {
        let hour = timeEnd / 3600
        let minute = (timeEnd / 60) % 60
        let second = timeEnd % 60
        return calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: second,
            of: Date(),
            direction: .forward) ??
            calendar.date(
                bySettingHour: hour,
                minute: minute,
                second: second,
                of: Date()) ?? Date()
    }

    private lazy var fromSelectionLabel = Label(
        style: .xsmall, text: "",
        color: Color.mainText, lines: 1)

    private lazy var fromArrowImage = Image(
        asset: .triangleDown, tint: Color.mainText)

    private lazy var fromBox: UIView = {
        let view = UIView()
        view.layer.borderColor = Color.lightGray.cgColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 6
        view.backgroundColor = Color.lightBackground

        fromSelectionLabel.textAlignment = .center
        view.addWithConstraints(view: fromSelectionLabel) {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }

        view.addWithConstraints(view: fromArrowImage) {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(fromSelectionLabel.snp.trailing)
            $0.trailing.equalToSuperview().offset(-6)
            $0.width.equalTo(8)
            $0.height.equalTo(8)
        }

        view.snp.makeConstraints {
            $0.width.equalTo(53)
            $0.height.equalTo(12)
        }

        return view
    }()

    private lazy var toSelectionLabel = Label(
        style: .xsmall, text: "",
        color: Color.mainText, lines: 1)

    private lazy var toArrowImage = Image(
        asset: .triangleDown, tint: Color.mainText)

    private lazy var toBox: UIView = {
        let view = UIView()
        view.layer.borderColor = Color.lightGray.cgColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 6
        view.backgroundColor = Color.lightBackground

        toSelectionLabel.textAlignment = .center
        view.addWithConstraints(view: toSelectionLabel) {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }

        view.addWithConstraints(view: toArrowImage) {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(toSelectionLabel.snp.trailing)
            $0.trailing.equalToSuperview().offset(-6)
            $0.width.equalTo(8)
            $0.height.equalTo(8)
        }

        view.snp.makeConstraints {
            $0.width.equalTo(53)
            $0.height.equalTo(12)
        }

        return view
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(" ", for: .normal)
        button.setImage(ImageAsset.closeSmallGreen.image, for: .normal)
        button.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        button.snp.makeConstraints {
            $0.width.equalTo(14)
            $0.height.equalTo(14)
        }
        return button
    }()

    private lazy var tapStartDetector = UITapGestureRecognizer(
        target: self,
        action: #selector(changeStartTapped)
    )

    private lazy var tapEndDetector = UITapGestureRecognizer(
        target: self,
        action: #selector(changeEndTapped)
    )

    init(timeStart: Int, timeEnd: Int, duration: Int, canDelete: Bool, delegate: RangeBlockDelegate?) {
        self.delegate = delegate
        self.timeStart = timeStart
        self.timeEnd = timeEnd
        self.duration = duration
        self.canDelete = canDelete

        super.init(frame: .zero)

        createLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(timeStart: Int) {
        self.timeStart = timeStart
    }

    func update(timeEnd: Int) {
        self.timeEnd = timeEnd
    }

    private func createLayout() {
        fromBox.isUserInteractionEnabled = true
        fromBox.addGestureRecognizer(tapStartDetector)
        addWithConstraints(view: fromBox) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-6)
            $0.top.equalToSuperview().offset(6)
        }

        toBox.isUserInteractionEnabled = true
        toBox.addGestureRecognizer(tapEndDetector)
        addWithConstraints(view: toBox) {
            $0.leading.equalToSuperview()
            $0.top.equalTo(fromBox.snp.bottom).offset(4)
            $0.bottom.equalToSuperview()
        }

        if canDelete {
            addWithConstraints(view: closeButton) {
                $0.top.equalToSuperview().offset(-2)
                $0.trailing.equalToSuperview().offset(6)
            }
        }

        updateLayout()
    }

    func updateLayout() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        fromSelectionLabel.text = dateFormatter.string(from: timeStartAsDate)
        toSelectionLabel.text = dateFormatter.string(from: timeEndAsDate)
    }

    @objc func deleteTapped() {
        delegate?.deleteRange(startTime: timeStart)
    }

    @objc func changeStartTapped() {
        delegate?.modifyStartRange(initialTime: (timeStart, timeEnd))
    }

    @objc func changeEndTapped() {
        delegate?.modifyEndRange(initialTime: (timeStart, timeEnd))
    }
}
