import UIKit

class GuestBookedExperiencesScreen: Screen<GuestBookedExperiencesLayout> {
    lazy var adapter = GuestBookedExperiencesAdapter()

    var buyController: ChatPurchaseController?

    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self

        adapter.swipeView = layout.svReservations
        adapter.pageIndicatorView = layout.pageIndicatorView

        buyController = ChatPurchaseController(viewController: self, isPopup: false)

        loadReservations()
    }

    func loadReservations() {
        ReservationIndexRequest()
            .performRequestWithDelegate { [weak self] response, error in
            self?.loader.dismiss()
            if let error = error {
                self?.show(error: error.localizedDescription)
                return
            }

            if let self = self {
                self.adapter.setData(
                    reservations: response?.result.data ?? [],
                    delegate: self)
            }
        }
    }
}

extension GuestBookedExperiencesScreen: InvoiceViewDelegate {
    func joinMeeting(reservation: ReservationIndexResponseResult) {
        if let link = reservation.google_meet_link,
           let url = URL(string: link) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func cancelMeeting(reservation: ReservationIndexResponseResult) {
        let alert = UIAlertController(title: "Are you sure?", message: "Reservation will be cancelled", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel reservation", style: .destructive) { [weak self] _ in
            self?.doCancel(reservation: reservation)
        })
        alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    private func doCancel(reservation: ReservationIndexResponseResult) {
        loader.show()
        ReservationCancelRequest(
            reservationId: reservation.id,
            userType: "guest")
            .performRequestWithDelegate { [weak self] response, error in
            if let error = error {
                self?.loader.dismiss()
                self?.show(error: error.localizedDescription)
            } else {
                self?.loadReservations()
            }
        }
    }
}
