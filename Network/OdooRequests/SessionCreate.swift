import Foundation

struct SessionCreateSessionRequestParams: Encodable {
    var start_datetime: String
}

struct SessionCreateRequestParams: Encodable {
    var experience_id: Int
    var sessions: [SessionCreateSessionRequestParams]
}

class SessionCreateRequest: BaseRequest<SessionCreateRequestParams, SessionCreateResponse> {
    init(experienceId: Int, startDateTime: [Date]) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        super.init(
            params: SessionCreateRequestParams(
                experience_id: experienceId,
                sessions: startDateTime.map {
                    SessionCreateSessionRequestParams(
                        start_datetime: dateFormatter.string(from: $0)
                    )
                }
            )
        )
    }

    override var route: OdooRoute {
        .sessionCreate
    }
}

struct SessionCreateResponseResult: Decodable {
    var status: Bool
    var message: String
}

class SessionCreateResponse: BaseDataResponse<SessionCreateResponseResult> {
}
