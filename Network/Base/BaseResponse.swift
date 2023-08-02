import Foundation

class BaseResponse<R: Decodable>: Decodable {
    var jsonrpc: String
    var result: R
}
