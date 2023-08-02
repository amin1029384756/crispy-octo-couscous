import Foundation

class LanguageIdRequest: BaseRequest<LanguageRequestParams, LanguageResponse> {
    init(id: Int) {
        super.init(
            params: LanguageRequestParams(),
            id: id
        )
    }

    override var route: OdooRoute {
        .languageId
    }
}
