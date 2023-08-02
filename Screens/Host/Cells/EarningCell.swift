import UIKit

protocol EarningCellDelegate: AnyObject {
    func cancel(earning: EarningIndexResponseResult)
    func meet(earning: EarningIndexResponseResult)
    func addToCalendar(earning: EarningIndexResponseResult)
}

class EarningCell: UITableViewCell {
    weak var delegate: EarningCellDelegate?
    var earning: EarningIndexResponseResult?

    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 22
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    lazy var nameLabel = Label(
        style: .regular,
        text: "",
        color: UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.00),
        lines: 1)

    lazy var experienceLabel = Label(
        style: .small,
        text: "",
        color: Color.mainText,
        lines: 1)

    lazy var dateLabel = Label(
        style: .small,
        text: "",
        color: Color.mainText,
        lines: 1)

    lazy var timeLabel = Label(
        style: .small,
        text: "",
        color: Color.mainText,
        lines: 1)

    lazy var meetButton = Button(
        style: .green,
        shape: .roundedRectangle(height: 23),
        title: "MEET",
        image: nil,
        delegate: self)

    lazy var statusLabel = Label(
        style: .small,
        text: "CANCELED",
        color: Color.purple,
        lines: 1)

    lazy var cancelButtonLabel = Label(
        style: .small,
        text: "CANCEL",
        color: Color.main,
        lines: 1)

    lazy var earningTitleLabel = Label(
        style: .small,
        text: "YOUR EARNING:",
        color: Color.mainText,
        lines: 1)

    lazy var earningAmountLabel = Label(
        style: .smallBold,
        text: "$0",
        color: Color.mainText,
        lines: 1)

    lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.86, green: 0.86, blue: 0.86, alpha: 1.00)
        return view
    }()

    lazy var cancelTapDetector = UITapGestureRecognizer(target: self, action: #selector(cancelTapped))

    var tooEarly = false
    var tooLate = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        createLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createLayout() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addWithConstraints(view: avatarImageView) {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(26)
            $0.width.equalTo(44)
            $0.height.equalTo(44)
        }

        contentView.addWithConstraints(view: meetButton) {
            $0.top.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-18)
            $0.width.equalTo(100)
        }

        contentView.addWithConstraints(view: nameLabel) {
            $0.top.equalToSuperview().offset(6)
            $0.leading.equalTo(avatarImageView.snp.trailing).offset(11)
            $0.trailing.equalTo(meetButton.snp.leading).offset(-4)
        }

        contentView.addWithConstraints(view: experienceLabel) {
            $0.top.equalTo(nameLabel.snp.bottom)
            $0.leading.equalTo(nameLabel.snp.leading)
            $0.trailing.equalTo(nameLabel.snp.trailing)
        }

        contentView.addWithConstraints(view: dateLabel) {
            $0.top.equalTo(experienceLabel.snp.bottom)
            $0.leading.equalTo(nameLabel.snp.leading)
            $0.trailing.equalTo(nameLabel.snp.trailing)
        }

        contentView.addWithConstraints(view: timeLabel) {
            $0.top.equalTo(dateLabel.snp.bottom)
            $0.leading.equalTo(nameLabel.snp.leading)
            $0.trailing.equalTo(nameLabel.snp.trailing)
        }

        contentView.addWithConstraints(view: separatorLine) {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(timeLabel.snp.bottom).offset(22)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }

        contentView.addWithConstraints(view: earningAmountLabel) {
            $0.bottom.equalTo(separatorLine.snp.top).offset(-7)
            $0.trailing.equalToSuperview().offset(-19)
        }

        contentView.addWithConstraints(view: earningTitleLabel) {
            $0.lastBaseline.equalTo(earningAmountLabel.snp.lastBaseline)
            $0.trailing.equalTo(earningAmountLabel.snp.leading).offset(-2)
        }

        cancelButtonLabel.isUserInteractionEnabled = true
        cancelButtonLabel.addGestureRecognizer(cancelTapDetector)
        contentView.addWithConstraints(view: cancelButtonLabel) {
            $0.bottom.equalTo(earningAmountLabel.snp.top)
            $0.trailing.equalTo(earningAmountLabel.snp.trailing)
        }

        statusLabel.isHidden = true
        addWithConstraints(view: statusLabel) {
            $0.centerY.equalTo(meetButton.snp.centerY)
            $0.trailing.equalTo(meetButton.snp.trailing)
        }
    }

    func prepare(earning: EarningIndexResponseResult, delegate: EarningCellDelegate?) {
        self.earning = earning
        self.delegate = delegate
        nameLabel.text = earning.payer_name ?? ""
        experienceLabel.text = earning.reservation.experience.name
        dateLabel.text = ""
        timeLabel.text = ""
        if let startDateTime = earning.reservation.reservation_session.getStartDateTime() {
            let dateDF = DateFormatter()
            dateDF.dateFormat = "d MMMM yyyy"
            let timeDF = DateFormatter()
            timeDF.dateFormat = "HH:mma"
            dateLabel.text = dateDF.string(from: startDateTime)
            var timeString = timeDF.string(from: startDateTime)
            if let endDateTime = earning.reservation.reservation_session.getEndDateTime() {
                timeString += " - " + timeDF.string(from: endDateTime)
            }
            timeLabel.text = timeString
        }
        let strAmount = String(format: "$%.02f", earning.amount)
        earningAmountLabel.text = strAmount
        let isCanceled = earning.reservation.status.lowercased() == "canceled"
        if isCanceled {
            cancelButtonLabel.isHidden = true
            statusLabel.isHidden = false
        } else {
            cancelButtonLabel.isHidden = false
            statusLabel.isHidden = true
        }
        tooEarly = false
        tooLate = false
        if let startTime = earning.reservation.reservation_session.getStartDateTime(),
            Date().timeIntervalSince1970 < startTime.timeIntervalSince1970 - 1800 {
            tooEarly = true
        }
        if let endTime = earning.reservation.reservation_session.getEndDateTime(),
                  Date().timeIntervalSince1970 > endTime.timeIntervalSince1970 + 1800 {
            tooLate = true
        }
        if let startTime = earning.reservation.reservation_session.getStartDateTime(),
           Date().timeIntervalSince1970 >= startTime.timeIntervalSince1970 {
            cancelButtonLabel.isHidden = true
        } else if isCanceled {
            cancelButtonLabel.isHidden = true
        } else {
            cancelButtonLabel.isHidden = false
        }
        if earning.reservation.google_meet_link != nil,
           !isCanceled {
            if tooLate {
                meetButton.isHidden = true
            } else if tooEarly {
                meetButton.titleLabel?.font = Font.bold[9]
                meetButton.setTitle("ADD TO CALENDAR", for: .normal)
                meetButton.isHidden = false
            } else {
                meetButton.titleLabel?.font = Font.bold[12]
                meetButton.setTitle("MEET", for: .normal)
                meetButton.isHidden = false
            }
        } else {
            meetButton.isHidden = true
        }
        if let profilePicture = earning.payer_profile_picture {
            avatarImageView.show(url: profilePicture)
        } else {
            avatarImageView.image = earning.payer_avatar?.base64Image
        }
    }

    @objc func cancelTapped() {
        if let earning = earning {
            delegate?.cancel(earning: earning)
        }
    }
}

extension EarningCell: ButtonDelegate {
    func buttonClicked(button: Button) {
        switch button {
        case meetButton:
            if let earning = earning {
                if tooEarly {
                    delegate?.addToCalendar(earning: earning)
                } else if !tooLate {
                    delegate?.meet(earning: earning)
                }
            }

        default:
            break
        }
    }
}
