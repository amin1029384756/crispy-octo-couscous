import Foundation

struct LanguageRequestParams: Encodable {
}

class LanguageRequest: BaseRequest<LanguageRequestParams, LanguageResponse> {
    init() {
        super.init(
            params: LanguageRequestParams()
        )
    }

    override var route: OdooRoute {
        .language
    }
}

struct LanguageResponseResult: Decodable {
    var id: Int
    var language: String
}

class LanguageResponse: BaseDataResponse<[LanguageResponseResult]> {
}
