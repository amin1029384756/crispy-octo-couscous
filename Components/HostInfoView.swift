import UIKit
import SnapKit

class HostInfoView: UIView {
    lazy var whoAmITitle = Label(
        style: .sectionTitle,
        text: "WHO AM I",
        color: Color.sectionTitle,
        lines: 1)

    lazy var whoAmIValue = Label(
        style: .detailsLarge,
        text: "",
        color: Color.detailsText,
        lines: 0)

    lazy var whereILiveTitle = Label(
        style: .sectionTitle,
        text: "WHICH CITY DO I LIVE IN",
        color: Color.sectionTitle,
        lines: 1)

    lazy var whereILiveValue = Label(
        style: .detailsLarge,
        text: "",
        color: Color.detailsText,
        lines: 0)

    lazy var emojiTitle = Label(
        style: .sectionTitle,
        text: "EMOJI THAT DESCRIBES ME BEST",
        color: Color.sectionTitle,
        lines: 1)

    lazy var emojiValue = Label(
        style: .detailsLarge,
        text: "",
        color: Color.detailsText,
        lines: 0)

    lazy var songTitle = Label(
        style: .sectionTitle,
        text: "SONG THAT DESCRIBES ME BEST",
        color: Color.sectionTitle,
        lines: 1)

    lazy var songValue = Label(
        style: .detailsLarge,
        text: "",
        color: Color.detailsText,
        lines: 0)

    lazy var personalityTypeTitle = Label(
        style: .sectionTitle,
        text: "PERSONALITY TYPE",
        color: Color.sectionTitle,
        lines: 1)

    lazy var personalityTypeValue = Label(
        style: .detailsLarge,
        text: "",
        color: Color.detailsText,
        lines: 0)

    lazy var funFactTitle = Label(
        style: .sectionTitle,
        text: "FUN FACT",
        color: Color.sectionTitle,
        lines: 1)

    lazy var funFactValue = Label(
        style: .detailsLarge,
        text: "",
        color: Color.detailsText,
        lines: 0)

    init() {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(hostInfo: HostInfo?) {
        guard let hostInfo = hostInfo,
              !hostInfo.isEmpty
        else {
            snp.makeConstraints {
                $0.height.equalTo(-12)
            }
            return
        }

        var previousView: UIView?
        if let whoAmI = hostInfo.whoAmI, !whoAmI.isEmpty {
            addWithConstraints(view: whoAmITitle) {
                $0.fillHorizontally()
                if let previousView = previousView {
                    $0.below(previousView, padding: 12)
                } else {
                    $0.top.equalToSuperview()
                }
            }

            whoAmIValue.text = whoAmI
            addWithConstraints(view: whoAmIValue) {
                $0.fillHorizontally()
                $0.below(whoAmITitle, padding: 4)
            }

            previousView = whoAmIValue
        }

        if let whereILive = hostInfo.whereILive, !whereILive.isEmpty {
            addWithConstraints(view: whereILiveTitle) {
                $0.fillHorizontally()
                if let previousView = previousView {
                    $0.below(previousView, padding: 12)
                } else {
                    $0.top.equalToSuperview()
                }
            }

            whereILiveValue.text = whereILive
            addWithConstraints(view: whereILiveValue) {
                $0.fillHorizontally()
                $0.below(whereILiveTitle, padding: 4)
            }

            previousView = whereILiveValue
        }

        if let emoji = hostInfo.emoji, !emoji.isEmpty {
            addWithConstraints(view: emojiTitle) {
                $0.fillHorizontally()
                if let previousView = previousView {
                    $0.below(previousView, padding: 12)
                } else {
                    $0.top.equalToSuperview()
                }
            }

            emojiValue.text = emoji
            addWithConstraints(view: emojiValue) {
                $0.fillHorizontally()
                $0.below(emojiTitle, padding: 4)
            }

            previousView = emojiValue
        }

        if let song = hostInfo.song, !song.isEmpty {
            addWithConstraints(view: songTitle) {
                $0.fillHorizontally()
                if let previousView = previousView {
                    $0.below(previousView, padding: 12)
                } else {
                    $0.top.equalToSuperview()
                }
            }

            songValue.text = song
            addWithConstraints(view: songValue) {
                $0.fillHorizontally()
                $0.below(songTitle, padding: 4)
            }

            previousView = songValue
        }

        if hostInfo.hasPersonalityType {
            addWithConstraints(view: personalityTypeTitle) {
                $0.fillHorizontally()
                if let previousView = previousView {
                    $0.below(previousView, padding: 12)
                } else {
                    $0.top.equalToSuperview()
                }
            }

            var personalityItems = [String]()
            if hostInfo.isExtrovert ?? false {
                personalityItems.append("Extrovert")
            }
            if hostInfo.isIntrovert ?? false {
                personalityItems.append("Introvert")
            }
            if hostInfo.isThinker ?? false {
                personalityItems.append("Thinker")
            }
            if hostInfo.isSocializer ?? false {
                personalityItems.append("Socializer")
            }
            if hostInfo.isSupporter ?? false {
                personalityItems.append("Supporter")
            }
            personalityTypeValue.text = personalityItems.joined(separator: " | ")
            addWithConstraints(view: personalityTypeValue) {
                $0.fillHorizontally()
                $0.below(personalityTypeTitle, padding: 4)
            }

            previousView = personalityTypeValue
        }

        if let funFact = hostInfo.funFact, !funFact.isEmpty {
            addWithConstraints(view: funFactTitle) {
                $0.fillHorizontally()
                if let previousView = previousView {
                    $0.below(previousView, padding: 12)
                } else {
                    $0.top.equalToSuperview()
                }
            }

            funFactValue.text = funFact
            addWithConstraints(view: funFactValue) {
                $0.fillHorizontally()
                $0.below(funFactTitle, padding: 4)
            }

            previousView = funFactValue
        }

        previousView?.snp.makeConstraints {
            $0.bottom.equalToSuperview()
        }
    }
}
