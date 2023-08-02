import Foundation

struct ReservationIndexRequestParams: Encodable {
}

class ReservationIndexRequest: BaseRequest<ReservationIndexRequestParams, ReservationIndexResponse> {
    init() {
        super.init(
            params: ReservationIndexRequestParams()
        )
    }

    override var route: OdooRoute {
        .reservationIndex
    }
}

struct ReservationIndexResponseResult: Decodable {
    var id: Int
    var reservation_session: SessionResponseResult
    var status: String
    var experience: ExperienceIndexResponseResult
    var google_meet_link: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case reservation_session
        case status
        case experience
        case google_meet_link
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        reservation_session = try container.decode(SessionResponseResult.self, forKey: .reservation_session)
        status = try container.decode(String.self, forKey: .status)
        experience = try container.decode(ExperienceIndexResponseResult.self, forKey: .experience)
        google_meet_link = try? container.decode(String.self, forKey: .google_meet_link)
    }

    init(id: Int, reservation_session: SessionResponseResult, status: String, experience: ExperienceIndexResponseResult, google_meet_link: String?) {
        self.id = id
        self.reservation_session = reservation_session
        self.status = status
        self.experience = experience
        self.google_meet_link = google_meet_link
    }
}

class ReservationIndexResponse: BaseDataResponse<[ReservationIndexResponseResult]> {
}
