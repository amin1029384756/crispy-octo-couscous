import Foundation

struct ApiPaymentOrderCompleteRequestParams: Encodable {
    var reservation_id: Int
    var amount: Double
    var data: String
}

class ApiPaymentOrderCompleteRequest: BaseRequest<ApiPaymentOrderCompleteRequestParams, ApiPaymentOrderCompleteResponse> {
    init(reservationId: Int, amount: Double, data: String) {
        super.init(
            params: ApiPaymentOrderCompleteRequestParams(
                reservation_id: reservationId,
                amount: amount,
                data: data
            )
        )
    }

    override var route: OdooRoute {
        .apiPaymentOrderComplete
    }
}

struct ApiPaymentOrderCompleteResponseResult: Decodable {
    var status: Bool
    var message: String
}

class ApiPaymentOrderCompleteResponse: BaseDataResponse<ApiPaymentOrderCompleteResponseResult> {
}
