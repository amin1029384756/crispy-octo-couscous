import Foundation

class SubcategoryIdRequest: BaseRequest<SubcategoryRequestParams, SubcategoryResponse> {
    init(id: Int) {
        super.init(
            params: SubcategoryRequestParams(),
            id: id
        )
    }

    override var route: OdooRoute {
        .subcategoryId
    }
}
