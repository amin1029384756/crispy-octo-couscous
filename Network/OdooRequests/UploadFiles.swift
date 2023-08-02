import Foundation

class UploadFilesRequest: BaseUploadRequest<UploadFilesResponse> {
    init(file: FileWithMetadata) {
        super.init(params: [
            "ufile": file
        ])
    }

    override var route: OdooRoute {
        .uploadFiles
    }
}

struct UploadFilesResponseResult: Decodable {
    var id: Int
    var url: String
}

struct UploadFilesResponse: Decodable {
    var status: Bool
    var attachments: [UploadFilesResponseResult]
}
