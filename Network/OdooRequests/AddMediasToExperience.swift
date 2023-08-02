import Foundation

struct AddMediasToExperienceMediaRequestParams: Encodable {
    var file_name: String
    var mime_type: String
    var url: String
    var key_s3: String
}

struct AddMediasToExperienceRequestParams: Encodable {
    var experience_id: Int
    var medias: [AddMediasToExperienceMediaRequestParams]
}

class AddMediasToExperienceRequest: BaseRequest<AddMediasToExperienceRequestParams, AddMediasToExperienceResponse> {
    init(experienceId: Int, medias: [AddMediasToExperienceMediaRequestParams]) {
        super.init(
            params: AddMediasToExperienceRequestParams(
                experience_id: experienceId,
                medias: medias
            )
        )
    }

    override var route: OdooRoute {
        .addMediasToExperience
    }
}

struct AddMediasToExperienceResponseResult: Decodable {
    var status: Bool
    var message: String
}

class AddMediasToExperienceResponse: BaseDataResponse<AddMediasToExperienceResponseResult> {
}
