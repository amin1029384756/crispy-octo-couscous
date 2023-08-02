import Foundation

struct LoginFirebaseRequestParams: Encodable {
    var uid: String
    var token: String
    var type: String
    var first_name: String
    var last_name: String
}

class LoginFirebaseRequest: BaseRequest<LoginFirebaseRequestParams, LoginFirebaseResponse> {
    init(uid: String, token: String, role: UserRole, firstName: String, lastName: String) {
        super.init(
            params: LoginFirebaseRequestParams(
                uid: uid,
                token: token,
                type: role == .host ? "host" : "guest",
                first_name: firstName,
                last_name: lastName
            )
        )
    }

    override var route: OdooRoute {
        .loginFirebase
    }
}

struct LoginFirebaseResponseResult: Decodable {
    var status: Bool
    var uid: String
    var message: String
    var guest_badge: Int?
    var host_badge: Int?
    var user: UserViewResponseResult?
}

class LoginFirebaseResponse: BaseDataResponse<LoginFirebaseResponseResult> {
}
