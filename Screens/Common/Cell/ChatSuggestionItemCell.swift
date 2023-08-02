import UIKit
import SnapKit
import FirebaseAuth

class ChatSuggestionItemCell: UITableViewCell {
    lazy var avatarView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Color.main
        imageView.layer.cornerRadius = 22
        imageView.layer.masksToBounds = true
        return imageView
    }()

    lazy var initialsLabel = Label(style: .nameLarge, text: "", color: .white, lines: 1)

    lazy var nameLabel = Label(
        style: .large,
        text: "",
        color: UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.00),
        lines: 1)

    lazy var messageLabel = Label(
        style: .groupTitle,
        text: "",
        color: .black,
        lines: 2)

    lazy var timeLabel = Label(
        style: .regular,
        text: "",
        color: UIColor(red: 0.53, green: 0.53, blue: 0.53, alpha: 1.00),
        lines: 1)

    lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.86, green: 0.86, blue: 0.86, alpha: 0.49)
        return view
    }()

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

        addWithConstraints(view: avatarView) {
            $0.centerY.equalToSuperview()
            $0.width.equalTo(44)
            $0.height.equalTo(44)
            $0.leading.equalToSuperview().offset(27)
        }

        initialsLabel.textAlignment = .center
        addWithConstraints(view: initialsLabel) {
            $0.center.equalTo(avatarView.snp.center)
        }

        timeLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        addWithConstraints(view: timeLabel) {
            $0.top.equalTo(avatarView.snp.top).offset(4)
            $0.trailing.equalToSuperview().offset(-21)
        }

        addWithConstraints(view: nameLabel) {
            $0.top.equalTo(avatarView.snp.top)
            $0.leading.equalTo(avatarView.snp.trailing).offset(12)
            $0.trailing.equalTo(timeLabel.snp.leading).offset(-8)
        }

        addWithConstraints(view: messageLabel) {
            $0.below(nameLabel, padding: 2)
            $0.leading.equalTo(avatarView.snp.trailing).offset(12)
            $0.trailing.equalTo(timeLabel.snp.leading).offset(-8)
        }

        addWithConstraints(view: separatorLine) {
            $0.leading.equalTo(nameLabel.snp.leading)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    func show(suggestion: KtorGetChatSuggestedGuestsResponse) {
        let name = suggestion.name
        let nameParts = name.components(separatedBy: " ")
        var initials = ""
        for namePart in nameParts where !namePart.isEmpty {
            if let firstLetter = namePart.first {
                initials.append(firstLetter)
            }
        }

        let text = "Tap to start a new chat"

        let date: String
        if let registrationDate = suggestion.registrationDate {
            if Date().dateWithoutTime.timeIntervalSince1970 == registrationDate.dateWithoutTime.timeIntervalSince1970 {
                date = ChatSuggestionItemCell.dateFormatterOnlyTime.string(from: registrationDate)
            } else {
                date = ChatSuggestionItemCell.dateFormatterWithDay.string(from: registrationDate)
            }
        } else {
            date = ""
        }

        initialsLabel.text = initials
        nameLabel.text = name
        messageLabel.text = text
        timeLabel.text = date

        messageLabel.set(style: .regular)
    }

    static let dateFormatterOnlyTime: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter
    }()

    static let dateFormatterWithDay: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy h:mm a"
        return dateFormatter
    }()
}
