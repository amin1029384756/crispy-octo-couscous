import Foundation

class BaseResponseError: Decodable {
    var code: Int?
    var message: String?
    var canTry: Bool?
}

class BaseDataResponseResult<R: Decodable>: Decodable {
    var status: Int
    var data: R?
    var message: String?
    var error: BaseResponseError?
}

class BaseDataResponse<R: Decodable>: Decodable {
    var jsonrpc: String
    var result: BaseDataResponseResult<R>
}
