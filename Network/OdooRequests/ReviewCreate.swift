import Foundation

struct ReviewCreateRequestParams: Encodable {
    var experience_id: Int
    var star: Int
    var comment: String
}

class ReviewCreateRequest: BaseRequest<ReviewCreateRequestParams, ReviewCreateResponse> {
    init(experienceId: Int, star: Int, comment: String) {
        super.init(
            params: ReviewCreateRequestParams(
                experience_id: experienceId,
                star: star,
                comment: comment
            )
        )
    }

    override var route: OdooRoute {
        .reviewCreate
    }
}

struct ReviewCreateResponseResult: Decodable {
    var status: Bool
    var message: String
}

class ReviewCreateResponse: BaseDataResponse<ReviewCreateResponseResult> {
}
