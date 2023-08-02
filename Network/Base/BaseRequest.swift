import Foundation
import Alamofire

class BaseRequest<A: Encodable, R: Decodable>: Encodable {
    var jsonrpc = "2.0"
    var params: A
    var id: Int?

    enum CodingKeys: String, CodingKey {
        case jsonrpc
        case params
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonrpc, forKey: .jsonrpc)
        try container.encode(params, forKey: .params)
    }

    var method: HTTPMethod {
        .post
    }

    var route: OdooRoute {
        fatalError("Route must be overridden")
    }

    init(params: A, id: Int? = nil) {
        self.params = params
        self.id = id
    }

    func performRequestWithDelegate(_ delegate: @escaping (_ response: R?, _ error: Error?) -> Void) {
        NetworkOdoo.performRequest(route: route, id: id, method: method, arguments: self, delegate: delegate)
    }

    func performRequest() async throws -> R {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<R, Error>) in
            performRequestWithDelegate { (result: R?, error: Error?) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let result = result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: ApiError.missingResponse)
                }
            }
        }
    }
}
