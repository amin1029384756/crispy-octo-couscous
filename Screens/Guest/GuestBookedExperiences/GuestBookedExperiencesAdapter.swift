import UIKit

class GuestBookedExperiencesAdapter: NSObject,
    SwipeViewDataSource, SwipeViewDelegate, PageIndicatorViewDelegate {
    weak var swipeView: SwipeView?
    weak var pageIndicatorView: PageIndicatorView?

    var reservations = [ReservationIndexResponseResult]()
    weak var delegate: InvoiceViewDelegate?

    func setData(reservations: [ReservationIndexResponseResult], delegate: InvoiceViewDelegate) {
        self.reservations = reservations
        self.delegate = delegate

        swipeView?.delegate = self
        swipeView?.dataSource = self

        pageIndicatorView?.delegate = self
        pageIndicatorView?.set(page: 0, pages: reservations.count)

        swipeView?.reloadData()
    }

    func numberOfItems(in swipeView: SwipeView!) -> Int {
        reservations.count
    }

    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        let invoiceView = (view as? InvoiceView) ??
            InvoiceView(reservation: nil, experience: nil, session: nil, allowActions: true, delegate: delegate)

        let reservation = reservations[index]
        let experience = reservation.experience
        let session = reservation.reservation_session
        invoiceView.set(reservation: reservation, experience: experience, session: session, allowActions: true)

        return invoiceView
    }

    func swipeViewCurrentItemIndexDidChange(_ swipeView: SwipeView!) {
        pageIndicatorView?.set(page: swipeView.currentItemIndex, pages: reservations.count)
    }

    func swipeViewItemSize(_ swipeView: SwipeView!) -> CGSize {
        CGSize(width: 291, height: 230)
    }

    func pageSelected(idx: Int) {
        swipeView?.scroll(toPage: idx, duration: 0.3)
    }
}
