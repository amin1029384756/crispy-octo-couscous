import Foundation

struct UserViewRequestParams: Encodable {
}

class UserViewRequest: BaseRequest<UserViewRequestParams, UserViewResponse> {
    init() {
        super.init(
            params: UserViewRequestParams()
        )
    }

    override var route: OdooRoute {
        .userView
    }
}

class UserViewResponse: BaseDataResponse<UserViewResponseResult> {
}
