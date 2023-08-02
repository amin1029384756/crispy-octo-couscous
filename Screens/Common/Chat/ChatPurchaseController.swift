import UIKit
import PayPalCheckout
import FirebaseFirestore

class ChatPurchaseController: NSObject {
    let layout = ChatPurchaseView(isPopup: true)

    weak var viewController: UIViewController?

    var loader: Loader!
    var isPopup: Bool

    init(viewController: UIViewController, isPopup: Bool) {
        self.isPopup = isPopup

        super.init()

        self.viewController = viewController
        layout.delegate = self

        loader = Loader(rootView: viewController.view)

        if isPopup {
            viewController.view.addWithConstraints(view: layout) {
                $0.edges.equalToSuperview()
            }
        } else {
            viewController.view.addWithConstraints(view: layout) {
                $0.fillHorizontally()
                $0.bottom.equalToSuperview()
            }
        }

        showRemainingMessages()
    }

    private func showRemainingMessages() {
        let messageLimit = User.active?.messageLimit ?? 0
        let messagesUsed = User.active?.messagesUsed ?? 0
        var remainingMessages = messageLimit - messagesUsed
        if remainingMessages < 0 {
            remainingMessages = 0
        }
        layout.remainingMessages.text = "REMAINING MESSAGES: \(remainingMessages)"
    }
}

extension ChatPurchaseController: ChatPurchaseViewDelegate {
    func purchase(messageCount: Int, price: Int) {
        let priceString = String(format: "%d.%02d", price / 100, price % 100)

        Checkout.setCurrencyCode(CurrencyCode.usd)

        Checkout.setCreateOrderCallback { createOrderAction in
            let amount = PurchaseUnit.Amount(currencyCode: .usd, value: priceString)
            let purchaseUnit = PurchaseUnit(amount: amount)
            let order = OrderRequest(intent: .capture, purchaseUnits: [purchaseUnit])

            createOrderAction.create(order: order)
        }

        Checkout.setOnApproveCallback { [weak self] approval in
            self?.loader.showIfNot()
            approval.actions.capture { [weak self] (response, error) in
                if let error = error {
                    self?.show(error: error.localizedDescription)
                    return
                }

                let dataString: String
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: response?.data.orderData ?? [:], options: .fragmentsAllowed)
                    dataString = String(data: jsonData, encoding: .utf8)!
                } catch {
                    self?.show(error: "Data string from PayPal is not available")
                    return
                }

                KtorChatsPurchaseRequest(
                    transactionInfo: dataString,
                    addMessages: messageCount,
                    price: price
                ).performRequestWithDelegate { [weak self] response, error in
                    if let error = error {
                        self?.show(error: error.localizedDescription)
                    } else if let error = response?.error {
                        self?.show(error: error.localizedDescription)
                    } else {
                        User.active?.messageLimit += messageCount
                        self?.reset()
                    }
                }
            }
        }

        Checkout.setOnCancelCallback { [weak self] in
            self?.loader.dismiss()
        }

        Checkout.setOnErrorCallback { [weak self] error in
            self?.show(error: error.error.localizedDescription)
        }

        Checkout.start()
    }

    func show(error: String) {
        loader.dismiss()
        let alert = UIAlertController(
            title: "Error",
            message: error,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        viewController?.present(alert, animated: true)
    }

    func reset() {
        loader.dismiss()

        showRemainingMessages()

        layout.slidingButton.isHidden = true
        layout.countCombo.selection = "0"
        layout.totalPriceLabel.text = "$0"
    }

    func dismiss() {
        loader.dismiss()
        if isPopup {
            layout.removeFromSuperview()
            (viewController as? ChatScreen)?.refresh()
        } else {
            (viewController as? BaseScreen)?.navigator.pop()
        }
    }
}
