import Foundation

struct UploadAttachmentRequestParams: Encodable {
    var attachment_base64: String
    var record_id: String
}

class UploadAttachmentRequest: BaseRequest<UploadAttachmentRequestParams, UploadAttachmentResponse> {
    init(attachment: Data) {
        let recordId = UUID().uuidString
        let attachmentBase64 = attachment.base64EncodedString()
        super.init(
            params: UploadAttachmentRequestParams(
                attachment_base64: attachmentBase64,
                record_id: recordId
            )
        )
    }

    override var route: OdooRoute {
        .uploadAttachment
    }
}

struct UploadAttachmentResponseResult: Decodable {
    var status: String
    var attachment_id: Int
    var url: String
}

class UploadAttachmentResponse: BaseDataResponse<UploadAttachmentResponseResult> {
}
