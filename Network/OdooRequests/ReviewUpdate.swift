import Foundation

struct ReviewUpdateRequestParams: Encodable {
    var id: Int
    var star: Int
    var comment: String
}

class ReviewUpdateRequest: BaseRequest<ReviewUpdateRequestParams, ReviewUpdateResponse> {
    init(id: Int, star: Int, comment: String) {
        super.init(
            params: ReviewUpdateRequestParams(
                id: id,
                star: star,
                comment: comment
            )
        )
    }

    override var route: OdooRoute {
        .reviewUpdate
    }
}

struct ReviewUpdateResponseResult: Decodable {
    var status: Bool
    var message: String
}

class ReviewUpdateResponse: BaseDataResponse<ReviewUpdateResponseResult> {
}
