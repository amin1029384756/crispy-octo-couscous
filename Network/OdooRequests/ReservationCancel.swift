import Foundation

struct ReservationCancelRequestParams: Encodable {
    var reservation_id: Int
    var user_type: String
}

class ReservationCancelRequest: BaseRequest<ReservationCancelRequestParams, ReservationCancelResponse> {
    init(reservationId: Int,
         userType: String) {
        super.init(
            params: ReservationCancelRequestParams(
                reservation_id: reservationId,
                user_type: userType
            )
        )
    }

    override var route: OdooRoute {
        .reservationCancel
    }
}

struct ReservationCancelResponseResult: Decodable {
    var status: Bool
    var message: String
}

class ReservationCancelResponse: BaseDataResponse<ReservationCancelResponseResult> {
}
