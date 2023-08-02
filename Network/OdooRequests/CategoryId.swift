import Foundation

class CategoryIdRequest: BaseRequest<CategoryRequestParams, CategoryResponse> {
    init(id: Int) {
        super.init(
            params: CategoryRequestParams(),
            id: id
        )
    }

    override var route: OdooRoute {
        .categoryId
    }
}
