import Foundation

struct ExperienceCreateIntroductoryVideo: Encodable {
    var id: Int
    var url: String
}

struct ExperienceCreateSession: Codable {
    var start_datetime: String

    func getStartDateTime() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: start_datetime)
    }
}

struct ExperienceCreateModel: Encodable {
    var category_id: Int
    var language_id: Int
    var description: String?
    var introductory_video: ExperienceCreateIntroductoryVideo?
    var sessions: [ExperienceCreateSession]
    var host_info: HostInfo?
}

struct ExperienceCreateRequestParams: Encodable {
    var experiences: [ExperienceCreateModel]
}

class ExperienceCreateRequest: BaseRequest<ExperienceCreateRequestParams, ExperienceCreateResponse> {
    init(experienceModel: ExperienceCreateModel) {
        super.init(
            params: ExperienceCreateRequestParams(experiences: [
                experienceModel
            ])
        )
    }

    override var route: OdooRoute {
        .experienceCreate
    }
}

struct ExperienceCreateResponseResult: Decodable {
    var status: Bool
    var message: String
    var experience_ids: [Int]
}

class ExperienceCreateResponse: BaseDataResponse<ExperienceCreateResponseResult> {
}
