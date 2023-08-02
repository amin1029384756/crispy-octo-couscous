import UIKit
import PayPalCheckout

class GuestWalletPayScreen: ScreenWithInput<GuestWalletPayLayout, GuestWalletPayArguments> {
    var experience: ExperienceIndexResponseResult?
    var selectedSession: SessionResponseResult?
    var reservationId: Int?
    var acceptedTerms = false

    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self
    }

    private func bookForFree() {
        guard let reservationId = reservationId else {
            show(error: "Reservation id is not available")
            return
        }

        loader.showIfNot()

        let orderCompleteRequest = ApiPaymentOrderCompleteRequest(
            reservationId: reservationId,
            amount: 0.0,
            data: "{}")
            .performRequestWithDelegate { [weak self] response, error in
                if let error = error {
                    self?.show(error: error.localizedDescription)
                    return
                }

                Wylytics.reportPurchase(
                    transactionId: "\(reservationId)",
                    itemId: self?.experience?.id ?? 0,
                    itemName: self?.experience?.name ?? "",
                    price: 0.0,
                    tax: 0.0)

                if response?.result.data?.status == true {
                    self?.loader.dismiss()
                    self?.createMeetingLink(reservationId: reservationId)
                } else {
                    self?.show(error: "Unexpected completion status")
                }
            }
    }

    func pay() {
        if !acceptedTerms {
            show(error: "Accept our terms of use and privacy policy before paying")
            return
        }

        guard let price = experience?.price else {
            show(error: "Price not found")
            return
        }

        if price < 0.01 {
            bookForFree()
            return
        }

        let priceString = String(format: "%.02f", price)

        Checkout.setCurrencyCode(CurrencyCode.usd)

        Checkout.setCreateOrderCallback { createOrderAction in
            let amount = PurchaseUnit.Amount(currencyCode: .usd, value: priceString)
            let purchaseUnit = PurchaseUnit(amount: amount)
            let order = OrderRequest(intent: .capture, purchaseUnits: [purchaseUnit])

            createOrderAction.create(order: order)
        }

        Checkout.setOnApproveCallback { [weak self] approval in
            guard let reservationId = self?.reservationId else {
                self?.show(error: "Reservation id is not available")
                return
            }

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

                let orderCompleteRequest = ApiPaymentOrderCompleteRequest(
                    reservationId: reservationId,
                    amount: price,
                    data: dataString)
                    .performRequestWithDelegate { [weak self] response, error in
                    if let error = error {
                        self?.show(error: error.localizedDescription)
                        return
                    }

                    Wylytics.reportPurchase(
                        transactionId: "\(reservationId)",
                        itemId: self?.experience?.id ?? 0,
                        itemName: self?.experience?.name ?? "",
                        price: price,
                        tax: 0.0)

                    if response?.result.data?.status == true {
                        self?.loader.dismiss()
                        self?.createMeetingLink(reservationId: reservationId)
                    } else {
                        self?.show(error: "Unexpected completion status")
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

    private func createMeetingLink(reservationId: Int) {
        guard let experience = experience,
              let session = selectedSession,
              let startDateTime = session.getStartDateTime(),
              let endDateTime = session.getEndDateTime()
        else {
            navigator.navigate(to: GuestBookSuccessScreen.self)
            return
        }

        CalendarUtil.shared.createEvent(
            eventName: experience.name,
            startDateTime: startDateTime,
            endDateTime: endDateTime
        ) { [weak self] meetLink, error in
            if let error = error {
                self?.show(error: error.localizedDescription)
                return
            }

            ReservationUpdateLinkRequest(
                reservationId: reservationId,
                link: meetLink ?? "")
                .performRequestWithDelegate { [weak self] _, error in
                if let error = error {
                    self?.show(error: error.localizedDescription)
                    return
                }

                self?.navigator.navigate(to: GuestBookSuccessScreen.self)
            }
        }
    }

    override func input(_ argument: GuestWalletPayArguments) {
        experience = argument.experience
        selectedSession = argument.selectedSession
        reservationId = argument.reservationId

        loadViewIfNeeded()

        let reservation = ReservationIndexResponseResult(
            id: argument.reservationId,
            reservation_session: argument.selectedSession,
            status: "unpaid",
            experience: argument.experience,
            google_meet_link: nil)
        layout.invoiceView.set(reservation: reservation, experience: argument.experience, session: argument.selectedSession, allowActions: false)
        if let price = argument.experience.price {
            layout.slidingButton.show(amount: price)
            let priceFormatted: String
            if price < 0.01 {
                layout.payPalImage.isHidden = true
                layout.serviceFeeValueLabel.text = "FREE"
                layout.totalLabel.text = "FREE"
            } else {
                layout.payPalImage.isHidden = false
                layout.serviceFeeValueLabel.text = String(format: "$%.02f", price)
                layout.totalLabel.text = String(format: "$%.02f", price)
            }
        }
    }
}
