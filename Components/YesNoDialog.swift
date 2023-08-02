import UIKit

class YesNoDialog: UIView {
    lazy var titleLabel = Label(
        style: .small,
        text: "",
        color: Color.mainText,
        lines: 0)

    lazy var textLabel = Label(
        style: .xsmall,
        text: "",
        color: Color.mainText,
        lines: 0)

    lazy var yesButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 5
        button.layer.borderColor = Color.main.cgColor
        button.layer.borderWidth = 1
        button.backgroundColor = .white
        button.setTitle("YES", for: .normal)
        button.setTitleColor(Color.main, for: .normal)
        button.titleLabel?.font = LabelStyle.regular.font
        return button
    }()

    lazy var noButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 5
        button.layer.borderColor = Color.main.cgColor
        button.layer.borderWidth = 1
        button.backgroundColor = .white
        button.setTitle("NO", for: .normal)
        button.setTitleColor(Color.main, for: .normal)
        button.titleLabel?.font = LabelStyle.regular.font
        return button
    }()

    lazy var containerCard: Card = {
        let card = Card()
        titleLabel.textAlignment = .center
        card.addWithConstraints(view: titleLabel) {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(26)
            $0.trailing.equalToSuperview().offset(-26)
        }

        card.addWithConstraints(view: textLabel) {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        card.addWithConstraints(view: yesButton) {
            $0.top.equalTo(textLabel.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(20)
            $0.bottom.equalToSuperview().offset(-16)
        }

        card.addWithConstraints(view: noButton) {
            $0.centerY.equalTo(yesButton.snp.centerY)
            $0.leading.equalTo(yesButton.snp.trailing).offset(8)
            $0.height.equalTo(20)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalTo(yesButton.snp.width)
        }

        return card
    }()

    private let delegate: (_ agreed: Bool) -> Void

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(title: String, text: String, delegate: @escaping (_ agreed: Bool) -> Void) {
        self.delegate = delegate

        super.init(frame: UIScreen.main.bounds)

        addWithConstraints(view: containerCard) {
            $0.leading.equalToSuperview().offset(54)
            $0.trailing.equalToSuperview().offset(-54)
            $0.centerY.equalToSuperview()
        }

        titleLabel.text = title
        textLabel.text = text

        yesButton.addTarget(self, action: #selector(yesTapped), for: .touchUpInside)
        noButton.addTarget(self, action: #selector(noTapped), for: .touchUpInside)
    }

    @objc func yesTapped() {
        delegate(true)
    }

    @objc func noTapped() {
        delegate(false)
    }
}
