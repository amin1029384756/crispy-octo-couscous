import Foundation

struct ExperienceDeleteRequestParams: Encodable {
    var experience_id: Int
}

class ExperienceDeleteRequest: BaseRequest<ExperienceDeleteRequestParams, ExperienceDeleteResponse> {
    init(experienceId: Int) {
        super.init(
            params: ExperienceDeleteRequestParams(experience_id: experienceId)
        )
    }

    override var route: OdooRoute {
        .experienceDelete
    }
}

struct ExperienceDeleteResponseResult: Decodable {
    var status: Bool
    var message: String
}

class ExperienceDeleteResponse: BaseDataResponse<ExperienceDeleteResponseResult> {
}
