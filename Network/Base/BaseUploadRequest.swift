import Foundation
import Alamofire

class BaseUploadRequest<R: Decodable> {
    var params: [String: Any]
    var id: Int?

    var route: OdooRoute {
        fatalError("Route must be overridden")
    }

    init(params: [String: Any], id: Int? = nil) {
        self.params = params
        self.id = id
    }

    func performRequestWithDelegate(delegate: @escaping (_ response: R?, _ error: Error?) -> Void) {
        NetworkOdoo.performUploadRequest(route: route, id: id, arguments: params, delegate: delegate)
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
