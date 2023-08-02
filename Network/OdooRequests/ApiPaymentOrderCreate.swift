import Foundation

struct ApiPaymentOrderCreateRequestParams: Encodable {
    var reservation_id: Int
    var amount: Double
}

class ApiPaymentOrderCreateRequest: BaseRequest<ApiPaymentOrderCreateRequestParams, ApiPaymentOrderCreateResponse> {
    init(reservationId: Int, amount: Double) {
        super.init(
            params: ApiPaymentOrderCreateRequestParams(
                reservation_id: reservationId,
                amount: amount
            )
        )
    }

    override var route: OdooRoute {
        .apiPaymentOrderCreate
    }
}

struct ApiPaymentOrderCreateResponseResult: Decodable {
    var status: Bool
    var txid: Int
    var url_checkout: String
    var message: String

    private enum CodingKeys: String, CodingKey {
        case status
        case txid
        case url_checkout
        case message
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(Bool.self, forKey: .status)
        do {
            txid = try container.decode(Int.self, forKey: .txid)
        } catch DecodingError.typeMismatch {
            txid = Int(try container.decode(String.self, forKey: .txid)) ?? 0
        }
        url_checkout = try container.decode(String.self, forKey: .url_checkout)
        message = try container.decode(String.self, forKey: .message)
    }
}

class ApiPaymentOrderCreateResponse: BaseDataResponse<ApiPaymentOrderCreateResponseResult> {
}
