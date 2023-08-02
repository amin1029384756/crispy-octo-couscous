import UIKit
import SnapKit

protocol ChatPurchaseViewDelegate: AnyObject {
    func purchase(messageCount: Int, price: Int)
    func dismiss()
}

class ChatPurchaseView: Layout {
    var messagesToBuy = 0
    var priceInCents = 0
    var isPopup = false

    weak var delegate: ChatPurchaseViewDelegate?

    lazy var panel: UIView = {
        let panelView = UIView()
        panelView.backgroundColor = .white

        remainingMessages.backgroundColor = UIColor(hex: 0xF0F0F0)
        remainingMessages.textAlignment = .center
        remainingMessages.layer.cornerRadius = 5
        remainingMessages.layer.masksToBounds = true
        panelView.addWithConstraints(view: remainingMessages) {
            $0.fillHorizontally(padding: 16)
            $0.top.equalToSuperview().offset(12)
            $0.height.equalTo(44)
        }

        panelView.addWithConstraints(view: purchaseMoreLabel) {
            $0.leading.equalToSuperview().offset(16)
            $0.below(remainingMessages, padding: 14)
        }

        qtyLabel.textAlignment = .center
        panelView.addWithConstraints(view: qtyLabel) {
            $0.centerY.equalTo(purchaseMoreLabel.snp.centerY)
            $0.leading.equalTo(purchaseMoreLabel.snp.trailing)
            $0.width.equalTo(60)
        }

        priceLabel.textAlignment = .center
        panelView.addWithConstraints(view: priceLabel) {
            $0.centerY.equalTo(purchaseMoreLabel.snp.centerY)
            $0.leading.equalTo(qtyLabel.snp.trailing)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalTo(60)
        }

        panelView.addWithConstraints(view: pricePerMessageLabel) {
            $0.leading.equalToSuperview().offset(16)
            $0.below(purchaseMoreLabel)
        }

        panelView.addWithConstraints(view: countCombo) {
            $0.below(qtyLabel, padding: 4)
            $0.width.equalTo(52)
            $0.height.equalTo(34)
            $0.centerX.equalTo(qtyLabel.snp.centerX)
        }

        totalPriceLabel.textAlignment = .center
        totalPriceLabel.backgroundColor = UIColor(hex: 0xE5E5E5)
        panelView.addWithConstraints(view: totalPriceLabel) {
            $0.below(priceLabel)
            $0.width.equalTo(44)
            $0.height.equalTo(34)
            $0.centerX.equalTo(priceLabel.snp.centerX)
        }

        slidingButton.isHidden = true
        panelView.addWithConstraints(view: slidingButton) {
            $0.below(countCombo, padding: 28)
            $0.fillHorizontally(padding: 26)
        }

        panelView.addWithConstraints(view: bottomBackButton) {
            $0.leading.equalToSuperview().offset(30)
            $0.bottom.equalToSuperview().offset(28)
            $0.below(slidingButton, padding: 14)
        }

        return panelView
    }()

    lazy var remainingMessages = Label(
        style: .sectionTitle,
        text: "REMAINING MESSAGES: ...",
        color: .black,
        lines: 1)

    lazy var purchaseMoreLabel = Label(
        style: .sectionTitle,
        text: "PURCHASE MORE",
        color: .black,
        lines: 1)

    lazy var pricePerMessageLabel = Label(
        style: .regular,
        text: "10¢/MESSAGE",
        color: .black,
        lines: 1)

    lazy var qtyLabel = Label(
        style: .sliderButton,
        text: "QTY",
        color: .black,
        lines: 1)

    lazy var priceLabel = Label(
        style: .sliderButton,
        text: "PRICE",
        color: .black,
        lines: 1)

    lazy var countCombo = ComboBox(
        optionList: [
            "0", "20", "40", "60", "80", "100"
        ],
        selection: "0",
        delegate: self)

    lazy var totalPriceLabel = Label(
        style: .titleLarge,
        text: "$0",
        color: .black,
        lines: 1)

    lazy var slidingButton = SlidingButton(amount: 0, delegate: self)

    lazy var bottomBackButton = ShadyBackButton(delegate: self)

    lazy var backGestureDetector = UITapGestureRecognizer(target: self, action: #selector(dismiss))

    required init() {
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(isPopup: Bool) {
        self.isPopup = isPopup

        super.init()
    }

    override func createLayout() {
        super.createLayout()

        if isPopup {
            backgroundColor = .black.withAlphaComponent(0.1)

            addWithConstraints(view: panel) {
                $0.fillHorizontally()
                $0.bottom.equalToSuperview()
            }

            let backView = UIView()
            backView.backgroundColor = .clear
            backView.isUserInteractionEnabled = true
            backView.addGestureRecognizer(backGestureDetector)
            addWithConstraints(view: backView) {
                $0.fillHorizontally()
                $0.top.equalToSuperview()
                $0.above(panel)
            }
        } else {
            addWithConstraints(view: panel) {
                $0.fillHorizontally()
                $0.bottom.equalToSuperview()
                $0.top.equalToSuperview()
            }
        }
    }

    @objc func dismiss() {
        delegate?.dismiss()
    }
}

extension ChatPurchaseView: ComboBoxDelegate {
    func comboBoxSelectionChanged(comboBox: ComboBox, selection: String) {
        messagesToBuy = Int(selection) ?? 0
        slidingButton.isHidden = messagesToBuy == 0
        priceInCents = messagesToBuy * 5
        slidingButton.show(amount: Double(priceInCents) / 100.0)
        totalPriceLabel.text = "$\(priceInCents / 100)"
    }
}

extension ChatPurchaseView: SlidingButtonDelegate {
    func slided() {
        if messagesToBuy <= 0 {
            return
        }

        delegate?.purchase(messageCount: messagesToBuy, price: priceInCents)
    }
}

extension ChatPurchaseView: ShadyBackButtonDelegate {
    func backTapped() {
        delegate?.dismiss()
    }
}
