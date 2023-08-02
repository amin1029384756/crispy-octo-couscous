import Foundation

class UploadAddMediaToExperienceRequest: BaseUploadRequest<UploadAddMediaToExperienceResponse> {
    init(experienceId: Int, file: FileWithMetadata) {
        super.init(params: [
            "ufile": file
        ], id: experienceId)
    }

    override var route: OdooRoute {
        .uploadAddMediaToExperience
    }
}

struct UploadAddMediaToExperienceAttachmentResult: Decodable {
    var id: Int
    var url: String
}

struct UploadAddMediaToExperienceMediaResult: Decodable {
    var id: Int
    var fileName: String
    var mimeType: String
    var url: String
}

struct UploadAddMediaToExperienceResponse: Decodable {
    var status: Bool
    var attachments: [UploadAddMediaToExperienceAttachmentResult]
    var medias: [UploadAddMediaToExperienceMediaResult]
}
