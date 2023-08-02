import UIKit
import EventKit
import EventKitUI

class HostEarningsScreen: Screen<HostEarningsLayout> {
    lazy var adapter = HostEarningsAdapter(delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self

        loader.showIfNot()
        loadEarnings()
    }

    override func refresh() {
        super.refresh()

        loadEarnings()
    }

    private func loadEarnings() {
        EarningIndexRequest()
            .performRequestWithDelegate { [weak self] response, error in
            guard let self = self else { return }

            self.layout.refreshControl.endRefreshing()
            self.loader.dismiss()

            if let error = error {
                self.show(error: error.localizedDescription)
                return
            }

            self.adapter.earnings = response?.result.data ?? []
            self.layout.list.delegate = self.adapter
            self.layout.list.dataSource = self.adapter
            self.layout.list.reloadData()
            if self.adapter.earnings.isEmpty {
                self.layout.list.isHidden = true
                self.layout.noReservationsLabel.isHidden = false
            } else {
                self.layout.list.isHidden = false
                self.layout.noReservationsLabel.isHidden = true
            }
        }
    }
}

extension HostEarningsScreen: EarningCellDelegate {
    func addToCalendar(earning: EarningIndexResponseResult) {
        guard let startDateTime = earning.reservation.reservation_session.getStartDateTime(),
              let endDateTime = earning.reservation.reservation_session.getEndDateTime()
        else {
            return
        }

        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { [weak self] granted, error in
            DispatchQueue.main.async { [weak self] in
                if let error = error {
                    self?.show(error: error.localizedDescription)
                } else if !granted {
                    self?.show(warning: "You need to grant calendar permission to add en event")
                } else {
                    let event = EKEvent(eventStore: eventStore)
                    let name = earning.payer_name ?? "Guest"
                    event.title = earning.reservation.experience.name + " with " + name
                    event.startDate = startDateTime
                    if let meetLink = earning.reservation.google_meet_link,
                       let url = URL(string: meetLink) {
                        event.location = meetLink
                        event.url = url
                    }
                    event.endDate = endDateTime
                    let eventController = EKEventEditViewController()
                    eventController.event = event
                    eventController.eventStore = eventStore
                    eventController.editViewDelegate = self
                    self?.present(eventController, animated: true, completion: nil)
                }
            }
        }
    }

    func cancel(earning: EarningIndexResponseResult) {
        let alert = UIAlertController(title: "Are you sure?", message: "Reservation will be cancelled", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel reservation", style: .destructive) { [weak self] _ in
            self?.doCancel(earning: earning)
        })
        alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    private func doCancel(earning: EarningIndexResponseResult) {
        loader.show()
        ReservationCancelRequest(
            reservationId: earning.reservation.id,
            userType: "host")
            .performRequestWithDelegate { [weak self] response, error in
            if let error = error {
                self?.loader.dismiss()
                self?.show(error: error.localizedDescription)
            } else {
                self?.loadEarnings()
            }
        }
    }

    func meet(earning: EarningIndexResponseResult) {
        if let linkString = earning.reservation.google_meet_link,
           let url = URL(string: linkString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension HostEarningsScreen: EKEventEditViewDelegate {
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }
}
