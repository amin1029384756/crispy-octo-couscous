import Foundation

struct ReservationUpdateStatusRequestParams: Encodable {
    var experience_id: Int
    var reservation_status: String
}

class ReservationUpdateStatusRequest: BaseRequest<ReservationUpdateStatusRequestParams, ReservationUpdateStatusResponse> {
    init(experienceId: Int, status: String) {
        super.init(
            params: ReservationUpdateStatusRequestParams(
                experience_id: experienceId,
                reservation_status: status
            )
        )
    }

    override var route: OdooRoute {
        .reservationUpdateStatus
    }
}

struct ReservationUpdateStatusResponseResult: Decodable {
    var status: Bool
    var reservation: ReservationIndexResponseResult
    var message: String
}

class ReservationUpdateStatusResponse: BaseDataResponse<ReservationUpdateStatusResponseResult> {
}
