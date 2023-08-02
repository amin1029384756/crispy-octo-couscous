import Foundation

struct LoginGoogleRequestParams: Encodable {
    var token: String
    var type: String
    var timezone: String = TimeZone.current.identifier
}

class LoginGoogleRequest: BaseRequest<LoginGoogleRequestParams, LoginGoogleResponse> {
    init(token: String, isHost: Bool) {
        super.init(
            params: LoginGoogleRequestParams(
                token: token,
                type: isHost ? "host" : "guest"
            )
        )
    }

    override var route: OdooRoute {
        .loginGoogle
    }
}

struct LoginGoogleResponseResult: Decodable {
    var status: Bool
    var uid: Int
    var message: String
}

class LoginGoogleResponse: BaseDataResponse<LoginGoogleResponseResult> {
}
