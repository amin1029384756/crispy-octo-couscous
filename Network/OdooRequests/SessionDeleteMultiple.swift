import Foundation

struct SessionDeleteMultipleRequestParams: Encodable {
    var session_ids: [Int]
}

class SessionDeleteMultipleRequest: BaseRequest<SessionDeleteMultipleRequestParams, SessionDeleteMultipleResponse> {
    init(sessionIds: [Int]) {
        super.init(
            params: SessionDeleteMultipleRequestParams(
                session_ids: sessionIds
            )
        )
    }

    override var route: OdooRoute {
        .sessionDeleteMultiple
    }
}

struct SessionDeleteMultipleResponseResult: Decodable {
    var status: Bool
    var message: String
}

class SessionDeleteMultipleResponse: BaseDataResponse<SessionDeleteMultipleResponseResult> {
}
