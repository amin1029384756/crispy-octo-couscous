import Foundation

struct ReservationCreateRequestParams: Encodable {
    var experience_id: Int
    var reservation_session: Int
}

class ReservationCreateRequest: BaseRequest<ReservationCreateRequestParams, ReservationCreateResponse> {
    init(experienceId: Int, reservationSession: Int) {
        super.init(
            params: ReservationCreateRequestParams(
                experience_id: experienceId,
                reservation_session: reservationSession
            )
        )
    }

    override var route: OdooRoute {
        .reservationCreate
    }
}

struct ReservationCreateResponseReservationResult: Decodable {
    var id: Int
    var reservation_session: SessionResponseResult
    var status: String
    var experience: ExperienceIndexResponseResult
    var google_meet_link: String?
}

struct ReservationCreateResponseResult: Decodable {
    var status: Bool
    var message: String
    var reservation: ReservationCreateResponseReservationResult?

    enum CodingKeys: String, CodingKey {
        case status
        case message
        case reservation
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decode(Bool.self, forKey: .status)
        message = try values.decode(String.self, forKey: .message)
        reservation = try values.decode(ReservationCreateResponseReservationResult?.self, forKey: .reservation)
    }
}

class ReservationCreateResponse: BaseDataResponse<ReservationCreateResponseResult> {
}
