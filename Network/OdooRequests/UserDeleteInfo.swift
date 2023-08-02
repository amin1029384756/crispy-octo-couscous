import Foundation

struct UserDeleteInfoRequestParams: Encodable {
}

class UserDeleteInfoRequest: BaseRequest<UserDeleteInfoRequestParams, UserDeleteInfoResponse> {
    init() {
        super.init(params: UserDeleteInfoRequestParams())
    }

    override var route: OdooRoute {
        .userDeleteInfo
    }
}

struct UserDeleteInfoResponseResult: Decodable {
    var status: Bool
    var message: String
}

class UserDeleteInfoResponse: BaseDataResponse<UserDeleteInfoResponseResult> {
}
