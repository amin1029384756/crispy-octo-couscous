import Foundation

struct SessionDeleteRequestParams: Encodable {
    var session_id: Int
}

class SessionDeleteRequest: BaseRequest<SessionDeleteRequestParams, SessionDeleteResponse> {
    init(sessionId: Int) {
        super.init(
            params: SessionDeleteRequestParams(
                session_id: sessionId
            )
        )
    }

    override var route: OdooRoute {
        .sessionDelete
    }
}

struct SessionDeleteResponseResult: Decodable {
    var status: Bool
    var message: String
}

class SessionDeleteResponse: BaseDataResponse<[SessionDeleteResponseResult]> {
}
