import Foundation

struct CategoryRequestParams: Encodable {
}

class CategoryRequest: BaseRequest<CategoryRequestParams, CategoryResponse> {
    init() {
        super.init(
            params: CategoryRequestParams()
        )
    }

    override var route: OdooRoute {
        .category
    }
}

struct CategoryResponseResult: Decodable {
    var id: Int
    var name: String
    var duration: Int
    var price: Double
    var subcategories: [SubcategoryResponseResult]
}

class CategoryResponse: BaseDataResponse<[CategoryResponseResult]> {
}
