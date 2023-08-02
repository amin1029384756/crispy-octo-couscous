import Foundation

struct ReservationUpdateLinkRequestParams: Encodable {
    var reservation_id: Int
    var google_meet_link: String
}

class ReservationUpdateLinkRequest: BaseRequest<ReservationUpdateLinkRequestParams, ReservationUpdateLinkResponse> {
    init(reservationId: Int, link: String) {
        super.init(
            params: ReservationUpdateLinkRequestParams(
                reservation_id: reservationId,
                google_meet_link: link
            )
        )
    }

    override var route: OdooRoute {
        .reservationUpdateLink
    }
}

struct ReservationUpdateLinkResponseResult: Decodable {
    var status: Bool
    var message: String
}

class ReservationUpdateLinkResponse: BaseDataResponse<ReservationUpdateLinkResponseResult> {
}
