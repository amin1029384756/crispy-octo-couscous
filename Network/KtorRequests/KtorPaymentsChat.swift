import Alamofire

struct KtorChatsPurchaseArguments: Encodable {
    let paymentPlatform: String
    let transactionInfo: String
    let addMessages: Int
    let price: Int
    let currency: String
}

class KtorChatsPurchaseRequest: KtorBaseRequest<KtorChatsPurchaseArguments, KtorBaseEmpty> {
    init(transactionInfo: String, addMessages: Int, price: Int) {
        super.init(args: KtorChatsPurchaseArguments(
            paymentPlatform: "PayPal",
            transactionInfo: transactionInfo,
            addMessages: addMessages,
            price: price,
            currency: "USD"
        ))
    }

    override var route: KtorRoute {
        .chatsPurchase
    }

    override var method: HTTPMethod {
        .post
    }
}
