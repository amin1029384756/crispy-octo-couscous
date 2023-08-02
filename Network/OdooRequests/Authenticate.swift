import Foundation

struct AuthenticateRequestParams: Encodable {
    var db = "Wythyou"
    var login: String
    var password: String
}

class AuthenticateRequest: BaseRequest<AuthenticateRequestParams, AuthenticateResponse> {
    init(login: String, password: String) {
        super.init(
            params: AuthenticateRequestParams(
                login: login,
                password: password
            )
        )
    }

    override var route: OdooRoute {
        .authenticate
    }
}

struct AuthenticateResponseResult: Decodable {
    var uid: Int
    var name: String
    var username: String
    var company_id: Int
    var partner_id: Int
    var user_id: [Int]
}

class AuthenticateResponse: BaseResponse<AuthenticateResponseResult> {
}
