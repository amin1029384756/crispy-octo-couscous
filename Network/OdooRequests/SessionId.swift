import Foundation

class SessionIdRequest: BaseRequest<SessionRequestParams, SessionResponse> {
    init(id: Int, experienceId: Int) {
        super.init(
            params: SessionRequestParams(
                experience_id: experienceId
            ),
            id: id
        )
    }

    override var route: OdooRoute {
        .sessionId
    }
}
