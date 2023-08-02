import UIKit
import SnapKit

class HostInfoFormInputView: UIView {
    lazy var title = Label(
        style: .small,
        text: "INFORMATION FOR YOUR GUESTS",
        color: Color.mainText,
        lines: 1)

    lazy var whoAmITitle = Label(
        style: .small,
        text: "WHO AM I:",
        color: Color.mainText,
        lines: 1)

    lazy var whoAmIField = TextField(delegate: self)

    lazy var whereILiveTitle = Label(
        style: .small,
        text: "WHICH CITY DO I LIVE IN:",
        color: Color.mainText,
        lines: 1)

    lazy var whereILiveField = TextField(delegate: self)

    lazy var emojiTitle = Label(
        style: .small,
        text: "EMOJI THAT DESCRIBES ME BEST:",
        color: Color.mainText,
        lines: 1)

    lazy var emojiField = TextField(delegate: self)

    lazy var songTitle = Label(
        style: .small,
        text: "SONG THAT DESCRIBES ME BEST:",
        color: Color.mainText,
        lines: 1)

    lazy var songField = TextField(delegate: self)

    lazy var personalityTypeLabel = Label(
        style: .small,
        text: "PERSONALITY TYPE (choose 1 or 2):",
        color: Color.mainText,
        lines: 1)

    lazy var isExtrovertCheckBox = QuizAnswerView(
        idx: 0,
        answer: "EXTROVERT",
        delegate: self
    )

    lazy var isIntrovertCheckBox = QuizAnswerView(
        idx: 1,
        answer: "INTROVERT",
        delegate: self
    )

    lazy var isThinkerCheckBox = QuizAnswerView(
        idx: 2,
        answer: "THINKER",
        delegate: self
    )

    lazy var isSocializerCheckBox = QuizAnswerView(
        idx: 3,
        answer: "SOCIALIZER",
        delegate: self
    )

    lazy var isSupporterCheckBox = QuizAnswerView(
        idx: 4,
        answer: "SUPPORTER",
        delegate: self
    )

    lazy var funFactTitle = Label(
        style: .small,
        text: "FUN FACT:",
        color: Color.mainText,
        lines: 1)

    lazy var funFactField = TextField(delegate: self)

    init() {
        super.init(frame: .zero)

        createLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createLayout() {
        addWithConstraints(view: title) {
            $0.fillHorizontally()
            $0.top.equalToSuperview()
        }

        addWithConstraints(view: whoAmITitle) {
            $0.fillHorizontally()
            $0.below(title, padding: 12)
        }

        addWithConstraints(view: whoAmIField) {
            $0.fillHorizontally()
            $0.below(whoAmITitle, padding: 8)
            $0.height.equalTo(24)
        }

        addWithConstraints(view: whereILiveTitle) {
            $0.fillHorizontally()
            $0.below(whoAmIField, padding: 12)
        }

        addWithConstraints(view: whereILiveField) {
            $0.fillHorizontally()
            $0.below(whereILiveTitle, padding: 8)
            $0.height.equalTo(24)
        }

        addWithConstraints(view: emojiTitle) {
            $0.fillHorizontally()
            $0.below(whereILiveField, padding: 12)
        }

        addWithConstraints(view: emojiField) {
            $0.fillHorizontally()
            $0.below(emojiTitle, padding: 8)
            $0.height.equalTo(24)
        }

        addWithConstraints(view: songTitle) {
            $0.fillHorizontally()
            $0.below(emojiField, padding: 12)
        }

        addWithConstraints(view: songField) {
            $0.fillHorizontally()
            $0.below(songTitle, padding: 8)
            $0.height.equalTo(24)
        }

        addWithConstraints(view: personalityTypeLabel) {
            $0.fillHorizontally()
            $0.below(songField, padding: 12)
        }

        addWithConstraints(view: isExtrovertCheckBox) {
            $0.leading.equalToSuperview()
            $0.below(personalityTypeLabel, padding: 8)
        }

        addWithConstraints(view: isIntrovertCheckBox) {
            $0.trailing.equalToSuperview()
            $0.below(personalityTypeLabel, padding: 8)
            $0.leading.equalTo(isExtrovertCheckBox.snp.trailing).offset(8)
            $0.width.equalTo(isExtrovertCheckBox.snp.width)
        }

        addWithConstraints(view: isThinkerCheckBox) {
            $0.leading.equalToSuperview()
            $0.below(isExtrovertCheckBox, padding: 8)
        }

        addWithConstraints(view: isSocializerCheckBox) {
            $0.trailing.equalToSuperview()
            $0.below(isIntrovertCheckBox, padding: 8)
            $0.leading.equalTo(isThinkerCheckBox.snp.trailing).offset(8)
            $0.width.equalTo(isThinkerCheckBox.snp.width)
        }

        addWithConstraints(view: isSupporterCheckBox) {
            $0.fillHorizontally()
            $0.below(isThinkerCheckBox, padding: 8)
        }

        addWithConstraints(view: funFactTitle) {
            $0.fillHorizontally()
            $0.below(isSupporterCheckBox, padding: 12)
            $0.height.equalTo(24)
        }

        addWithConstraints(view: funFactField) {
            $0.fillHorizontally()
            $0.below(funFactTitle, padding: 8)
            $0.height.equalTo(24)
        }

        if let lastSubview = subviews.last {
            lastSubview.snp.makeConstraints {
                $0.bottom.equalToSuperview()
            }
        }
    }

    func set(hostInfo: HostInfo) {
        whoAmIField.text = hostInfo.whoAmI ?? ""
        whereILiveField.text = hostInfo.whereILive ?? ""
        emojiField.text = hostInfo.emoji ?? ""
        songField.text = hostInfo.song ?? ""
        funFactField.text = hostInfo.funFact ?? ""
        isExtrovertCheckBox.isSelected = hostInfo.isExtrovert ?? false
        isIntrovertCheckBox.isSelected = hostInfo.isIntrovert ?? false
        isThinkerCheckBox.isSelected = hostInfo.isThinker ?? false
        isSocializerCheckBox.isSelected = hostInfo.isSocializer ?? false
        isSupporterCheckBox.isSelected = hostInfo.isSupporter ?? false
    }

    func get() -> HostInfo {
        HostInfo(
            whoAmI: whoAmIField.text ?? "",
            whereILive: whereILiveField.text ?? "",
            emoji: emojiField.text ?? "",
            song: songField.text ?? "",
            isExtrovert: isExtrovertCheckBox.isSelected,
            isIntrovert: isIntrovertCheckBox.isSelected,
            isThinker: isThinkerCheckBox.isSelected,
            isSocializer: isSocializerCheckBox.isSelected,
            isSupporter: isSupporterCheckBox.isSelected,
            funFact: funFactField.text ?? ""
        )
    }
}

extension HostInfoFormInputView: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

extension HostInfoFormInputView: PQuizAnswerViewDelegate {
    func answerSelected(idx: Int) {
        let checkBoxes = [isExtrovertCheckBox, isIntrovertCheckBox, isThinkerCheckBox,
            isSocializerCheckBox, isSupporterCheckBox]
        if checkBoxes[idx].isSelected {
            // Deselect
            checkBoxes[idx].isSelected = false
        } else {
            // Select if possible
            let selections = checkBoxes.filter { $0.isSelected }.count
            if selections < 2 {
                checkBoxes[idx].isSelected = true
            }
        }
    }
}
