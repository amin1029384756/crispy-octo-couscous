import UIKit
import SnapKit

class GuestCoinsLayout: Layout {
    lazy var topBar = TopBar(mode: .guest, title: nil, customTopView: chatButton, delegate: self)

    lazy var chatButton = ChatButton(delegate: self)

    lazy var collectCoinsLabel = Label(
        style: .screenTitle,
        text: "Collect coins, earn gifts",
        color: Color.mainText,
        lines: 1)

    lazy var coinShoppingImageView = Image(asset: .coinShopping)

    lazy var coinImageView = Image(asset: .wCoin)

    lazy var coinBalanceLabel = Label(
        style: .groupTitle,
        text: "\(User.active?.coins ?? 0) Coins",
        color: Color.main,
        lines: 1)

    lazy var surveyLabel = Label(
        style: .large,
        text: "Survey",
        color: Color.mainText,
        lines: 1)

    lazy var whatDoYouPreferLabel = Label(
        style: .smallBold,
        text: "What do you prefer to earn as awards for your coins?",
        color: Color.mainText,
        lines: 0)

    lazy var merchandiseAnswerView = QuizAnswerView(
        idx: 0,
        answer: "Branded company merchandise",
        delegate: self)

    lazy var merchandiseBarContainer = UIView()

    lazy var merchandiseBarProgress = UIView()

    lazy var merchandisePercentLabel = Label(
        style: .normal,
        text: "",
        color: Color.mainText,
        lines: 1)

    lazy var discountsAnswerView = QuizAnswerView(
        idx: 1,
        answer: "Discounts for purchasing text messages and calls\n",
        delegate: self)

    lazy var discountsBarContainer = UIView()

    lazy var discountsBarProgress = UIView()

    lazy var discountsPercentLabel = Label(
        style: .normal,
        text: "",
        color: Color.mainText,
        lines: 1)

    lazy var cryptoAnswerView = QuizAnswerView(
        idx: 2,
        answer: "WythYou cryptocurrency",
        delegate: self)

    lazy var cryptoBarContainer = UIView()

    lazy var cryptoBarProgress = UIView()

    lazy var cryptoPercentLabel = Label(
        style: .normal,
        text: "",
        color: Color.mainText,
        lines: 1)

    lazy var submitButton = Button(
        style: .green,
        shape: .roundedRectangle(height: 46),
        title: "Submit",
        image: nil,
        delegate: self)

    lazy var bottomBackButton = ShadyBackButton(delegate: self)

    var merchandiseBarWidth: ConstraintMakerEditable!
    var discountsBarWidth: ConstraintMakerEditable!
    var cryptoBarWidth: ConstraintMakerEditable!

    weak var screen: GuestCoinsScreen?

    override func createLayout() {
        super.createLayout()

        addWithConstraints(view: topBar) {
            $0.top.equalTo(layoutMarginsGuide.snp.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        collectCoinsLabel.textAlignment = .center
        addWithConstraints(view: collectCoinsLabel) {
            $0.below(topBar, padding: 30)
            $0.fillHorizontally(padding: 32)
        }

        addWithConstraints(view: coinShoppingImageView) {
            $0.width.equalTo(120)
            $0.height.equalTo(106)
            $0.leading.equalToSuperview().offset(60)
            $0.below(collectCoinsLabel, padding: 30)
        }

        addWithConstraints(view: coinImageView) {
            $0.top.equalTo(coinShoppingImageView.snp.top)
            $0.trailing.equalTo(coinShoppingImageView.snp.trailing)
            $0.width.equalTo(28)
            $0.height.equalTo(28)
        }

        addWithConstraints(view: coinBalanceLabel) {
            $0.centerY.equalTo(coinImageView.snp.centerY)
            $0.leading.equalTo(coinImageView.snp.trailing).offset(8)
        }

        surveyLabel.textAlignment = .center
        addWithConstraints(view: surveyLabel) {
            $0.below(coinShoppingImageView, padding: 26)
            $0.fillHorizontally(padding: 32)
        }

        whatDoYouPreferLabel.textAlignment = .natural
        addWithConstraints(view: whatDoYouPreferLabel) {
            $0.below(surveyLabel, padding: 24)
            $0.fillHorizontally(padding: 32)
        }

        addWithConstraints(view: merchandiseAnswerView) {
            $0.below(whatDoYouPreferLabel, padding: 24)
            $0.fillHorizontally(padding: 32)
        }

        merchandiseBarContainer.isHidden = true
        addWithConstraints(view: merchandiseBarContainer) {
            $0.below(whatDoYouPreferLabel, padding: 54)
            $0.fillHorizontally(padding: 64)
            $0.height.equalTo(4)
        }

        merchandiseBarProgress.isHidden = true
        addWithConstraints(view: merchandiseBarProgress) {
            $0.top.equalTo(merchandiseBarContainer.snp.top)
            $0.bottom.equalTo(merchandiseBarContainer.snp.bottom)
            $0.leading.equalTo(merchandiseBarContainer.snp.leading)
            merchandiseBarWidth = $0.width.equalTo(1)
        }

        merchandisePercentLabel.isHidden = true
        addWithConstraints(view: merchandisePercentLabel) {
            $0.centerY.equalTo(merchandiseBarContainer.snp.centerY)
            $0.leading.equalTo(merchandiseBarContainer.snp.trailing).offset(8)
        }

        addWithConstraints(view: discountsAnswerView) {
            $0.below(whatDoYouPreferLabel, padding: 74)
            $0.fillHorizontally(padding: 32)
        }

        discountsBarContainer.isHidden = true
        addWithConstraints(view: discountsBarContainer) {
            $0.below(whatDoYouPreferLabel, padding: 104)
            $0.fillHorizontally(padding: 64)
            $0.height.equalTo(4)
        }

        discountsBarProgress.isHidden = true
        addWithConstraints(view: discountsBarProgress) {
            $0.top.equalTo(discountsBarContainer.snp.top)
            $0.bottom.equalTo(discountsBarContainer.snp.bottom)
            $0.leading.equalTo(discountsBarContainer.snp.leading)
            discountsBarWidth = $0.width.equalTo(1)
        }

        discountsPercentLabel.isHidden = true
        addWithConstraints(view: discountsPercentLabel) {
            $0.centerY.equalTo(discountsBarContainer.snp.centerY)
            $0.leading.equalTo(discountsBarContainer.snp.trailing).offset(8)
        }

        addWithConstraints(view: cryptoAnswerView) {
            $0.below(whatDoYouPreferLabel, padding: 124)
            $0.fillHorizontally(padding: 32)
        }

        cryptoBarContainer.isHidden = true
        addWithConstraints(view: cryptoBarContainer) {
            $0.below(whatDoYouPreferLabel, padding: 154)
            $0.fillHorizontally(padding: 64)
            $0.height.equalTo(4)
        }

        cryptoBarProgress.isHidden = true
        addWithConstraints(view: cryptoBarProgress) {
            $0.top.equalTo(cryptoBarContainer.snp.top)
            $0.bottom.equalTo(cryptoBarContainer.snp.bottom)
            $0.leading.equalTo(cryptoBarContainer.snp.leading)
            cryptoBarWidth = $0.width.equalTo(1)
        }

        cryptoPercentLabel.isHidden = true
        addWithConstraints(view: cryptoPercentLabel) {
            $0.centerY.equalTo(cryptoBarContainer.snp.centerY)
            $0.leading.equalTo(cryptoBarContainer.snp.trailing).offset(8)
        }

        submitButton.isEnabled = false
        addWithConstraints(view: submitButton) {
            $0.below(cryptoAnswerView, padding: 40)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(146)
        }

        addWithConstraints(view: bottomBackButton) {
            $0.leading.equalToSuperview().offset(30)
            $0.bottom.equalToSuperview().offset(28)
        }
    }

    func show(selection: Int?, changeable: Bool) {
        merchandiseAnswerView.isSelected = selection == 0
        discountsAnswerView.isSelected = selection == 1
        cryptoAnswerView.isSelected = selection == 2

        if changeable {
            merchandiseAnswerView.isUserInteractionEnabled = true
            discountsAnswerView.isUserInteractionEnabled = true
            cryptoAnswerView.isUserInteractionEnabled = true
            submitButton.isEnabled = selection != nil
        } else {
            merchandiseAnswerView.isUserInteractionEnabled = false
            discountsAnswerView.isUserInteractionEnabled = false
            cryptoAnswerView.isUserInteractionEnabled = false
            submitButton.isEnabled = false
        }
    }

    func show(merchandiseCount: Int, discountsCount: Int, cryptoCount: Int) {
        let totalCount = merchandiseCount + discountsCount + cryptoCount
        if totalCount <= 0 {
            return
        }

        merchandiseBarContainer.backgroundColor = UIColor(red: 0.88, green: 0.88, blue: 0.87, alpha: 1.00)
        merchandiseBarContainer.isHidden = false
        merchandiseBarProgress.backgroundColor = Color.main
        merchandiseBarProgress.isHidden = false
        merchandiseBarWidth.constraint.update(offset: merchandiseBarContainer.bounds.width * CGFloat(merchandiseCount) / CGFloat(totalCount))
        merchandisePercentLabel.isHidden = false
        merchandisePercentLabel.text = String(format: "%02d%%", merchandiseCount * 100 / totalCount)

        discountsBarContainer.backgroundColor = UIColor(red: 0.88, green: 0.88, blue: 0.87, alpha: 1.00)
        discountsBarContainer.isHidden = false
        discountsBarProgress.backgroundColor = Color.main
        discountsBarProgress.isHidden = false
        discountsBarWidth.constraint.update(offset: discountsBarContainer.bounds.width * CGFloat(discountsCount) / CGFloat(totalCount))
        discountsPercentLabel.isHidden = false
        discountsPercentLabel.text = String(format: "%02d%%", discountsCount * 100 / totalCount)

        cryptoBarContainer.backgroundColor = UIColor(red: 0.88, green: 0.88, blue: 0.87, alpha: 1.00)
        cryptoBarContainer.isHidden = false
        cryptoBarProgress.backgroundColor = Color.main
        cryptoBarProgress.isHidden = false
        cryptoBarWidth.constraint.update(offset: cryptoBarContainer.bounds.width * CGFloat(cryptoCount) / CGFloat(totalCount))
        cryptoPercentLabel.isHidden = false
        cryptoPercentLabel.text = String(format: "%02d%%", cryptoCount * 100 / totalCount)
    }
}

extension GuestCoinsLayout: TopBarDelegate {
    func profileButtonClicked() {
        screen?.openProfile()
    }

    func rightButtonClicked() {
        screen?.openWallet()
    }
}

extension GuestCoinsLayout: ChatButtonDelegate {
    func openChatList() {
        screen?.openChatList()
    }
}

extension GuestCoinsLayout: ShadyBackButtonDelegate {
    func backTapped() {
        screen?.goBack()
    }
}

extension GuestCoinsLayout: PQuizAnswerViewDelegate {
    func answerSelected(idx: Int) {
        screen?.selection = idx
        submitButton.isEnabled = true
        show(selection: idx, changeable: true)
    }
}

extension GuestCoinsLayout: ButtonDelegate {
    func buttonClicked(button: Button) {
        switch button {
        case submitButton:
            screen?.submit()

        default:
            break
        }
    }
}
