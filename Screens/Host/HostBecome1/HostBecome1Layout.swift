import UIKit

class HostBecome1Layout: Layout {
    lazy var topBar = TopBar(mode: .host, title: "Become a Host", customTopView: nil, delegate: self)

    lazy var label1 = Label(
        style: .regular,
        text: "we are excited that you would like to offer new experienceS to the world.".uppercased(),
        color: Color.mainText,
        lines: 0)

    lazy var separatorLine = Image(asset: .separator)

    lazy var label2: Label = {
        let label = Label(
            style: .small,
            text: "hit the plus sign to CREATE YOUR experience ad!".uppercased(),
            color: Color.mainText,
            lines: 0)
        let text = NSMutableAttributedString()
        text.append(NSAttributedString(
            string: "hit the plus sign to CREATE YOUR ".uppercased(),
            attributes: [
                .font: LabelStyle.small.font,
                .foregroundColor: Color.mainText
            ]
        ))
        text.append(NSAttributedString(
            string: "experience ad!".uppercased(),
            attributes: [
                .font: LabelStyle.smallBold.font,
                .foregroundColor: Color.mainText
            ]
        ))

        label.attributedText = text
        return label
    }()

    lazy var becomeHostButton = ImageButton(asset: .becomeHost, delegate: self)

    weak var screen: HostBecome1Screen?

    override func createLayout() {
        addWithConstraints(view: topBar) {
            $0.top.equalTo(layoutMarginsGuide.snp.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        label1.textAlignment = .center
        addWithConstraints(view: label1) {
            $0.top.equalTo(topBar.snp.bottom).offset(100)
            $0.leading.equalToSuperview().offset(48)
            $0.trailing.equalToSuperview().offset(-48)
        }

        addWithConstraints(view: separatorLine) {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(label1.snp.bottom).offset(16)
        }

        label2.textAlignment = .center
        addWithConstraints(view: label2) {
            $0.top.equalTo(separatorLine.snp.bottom).offset(22)
            $0.leading.equalToSuperview().offset(48)
            $0.trailing.equalToSuperview().offset(-48)
        }

        addWithConstraints(view: becomeHostButton) {
            $0.centerX.equalToSuperview().offset(25)
            $0.top.equalTo(label2.snp.bottom).offset(8)
            $0.width.equalTo(127)
            $0.height.equalTo(176)
        }
    }
}

extension HostBecome1Layout: TopBarDelegate {
    func profileButtonClicked() {
        screen?.openProfile()
    }

    func rightButtonClicked() {
        screen?.openEarnings()
    }
}

extension HostBecome1Layout: ImageButtonDelegate {
    func imageButtonClicked(imageButton: ImageButton) {
        screen?.goNext()
    }
}
