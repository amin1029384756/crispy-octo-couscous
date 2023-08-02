import Foundation

struct SessionRequestParams: Encodable {
    var experience_id: Int
}

class SessionRequest: BaseRequest<SessionRequestParams, SessionResponse> {
    init(experienceId: Int) {
        super.init(
            params: SessionRequestParams(
                experience_id: experienceId
            )
        )
    }

    override var route: OdooRoute {
        .session
    }
}

struct SessionResponseResult: Codable {
    var id: Int
    var start_datetime: String
    var duration: Int
    var end_datetime: String
    var status: String?

    var isFull: Bool {
        status == "full"
    }

    func getStartDateTime() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: start_datetime)
    }

    func getEndDateTime() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: end_datetime)
    }
}

class SessionResponse: BaseDataResponse<[SessionResponseResult]> {
}
