import Foundation

struct SubcategoryRequestParams: Encodable {
}

class SubcategoryRequest: BaseRequest<SubcategoryRequestParams, SubcategoryResponse> {
    init() {
        super.init(
            params: SubcategoryRequestParams()
        )
    }

    override var route: OdooRoute {
        .subcategory
    }
}

struct SubcategoryResponseResult: Decodable {
    var id: Int
    var name: String
    var icon: String
    var category_id: Int
    var order: Int

    var isListen: Bool {
        id == 3 || id == 11
    }

    var isVideoOnly: Bool {
        id == 11
    }

    var isBookingAvailable: Bool {
        !isVideoOnly
    }
}

class SubcategoryResponse: BaseDataResponse<[SubcategoryResponseResult]> {
}
