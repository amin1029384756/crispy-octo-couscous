import Foundation

class UserUpdateRequest: BaseRequest<UserUpdateRequestParams, UserUpdateResponse> {
    override var route: OdooRoute {
        .userUpdate
    }
}

struct UserUpdateResponseResult: Decodable {
    var status: Bool
    var message: String
}

class UserUpdateResponse: BaseDataResponse<UserUpdateResponseResult> {
}
