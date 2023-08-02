import Foundation

struct EarningIndexRequestParams: Encodable {
}

class EarningIndexRequest: BaseRequest<EarningIndexRequestParams, EarningIndexResponse> {
    init() {
        super.init(
            params: EarningIndexRequestParams()
        )
    }

    override var route: OdooRoute {
        .earningIndex
    }
}

struct EarningIndexResponseResult: Decodable {
    var reservation: ReservationIndexResponseResult
    var payer_id: Int
    var payer_avatar: String?
    var payer_profile_picture: String?
    var payer_name: String?
    var amount: Double
}

class EarningIndexResponse: BaseDataResponse<[EarningIndexResponseResult]> {
}
