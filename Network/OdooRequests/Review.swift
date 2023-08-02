import Foundation

struct ReviewRequestParams: Encodable {
    var experience_id: Int
}

class ReviewRequest: BaseRequest<ReviewRequestParams, ReviewResponse> {
    init(experienceId: Int) {
        super.init(
            params: ReviewRequestParams(
                experience_id: experienceId
            )
        )
    }

    override var route: OdooRoute {
        .review
    }
}

struct ReviewResponseResult: Decodable {
    var id: Int
    var user_id: Int
    var experience_id: Int
    var star: Double
    var comment: String
}

class ReviewResponse: BaseDataResponse<[ReviewResponseResult]> {
}
