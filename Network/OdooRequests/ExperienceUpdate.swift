import Foundation

struct ExperienceUpdateIntroductoryVideo: Encodable {
    var id: Int
    var url: String
}

struct ExperienceUpdateModel: Encodable {
    var id: Int
    var category_id: Int
    var language_id: Int
    var description: String?
    var introductory_video: ExperienceUpdateIntroductoryVideo?
    var sessions: [SessionResponseResult]
    var host_info: HostInfo?
}

struct ExperienceUpdateRequestParams: Encodable {
    var experience: ExperienceUpdateModel
    var delete_medias: [Int]
}

class ExperienceUpdateRequest: BaseRequest<ExperienceUpdateRequestParams, ExperienceUpdateResponse> {
    let hasMediasToDelete: Bool

    init(experienceModel: ExperienceUpdateModel, deleteMedias: [Int]) {
        hasMediasToDelete = !deleteMedias.isEmpty
        super.init(
            params: ExperienceUpdateRequestParams(
                experience: experienceModel,
                delete_medias: deleteMedias
            )
        )
    }

    override var route: OdooRoute {
        if hasMediasToDelete {
            return .experienceUpdateDeleteMedias
        } else {
            return .experienceUpdate
        }
    }
}

struct ExperienceUpdateResponseResult: Decodable {
    var status: Bool
    var message: String
}

class ExperienceUpdateResponse: BaseDataResponse<ExperienceUpdateResponseResult> {
}
