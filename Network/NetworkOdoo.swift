import Alamofire
import FirebaseAuth

class NetworkOdoo {
    static let apiVersion = "v2"
    static let baseUrl = "https://panel.wythyou.com/wythyou-api/\(apiVersion)/"
    static let sessionUrl = "https://panel.wythyou.com/web/session/"

    static func getFullUrl(route: String) -> URL {
        if route.starts(with: "http://") || route.starts(with: "https://") ||
            route.starts(with: "file://"),
            let url = URL(string: route) {
            return url
        } else {
            if route == "authenticate" {
                return URL(string: "\(sessionUrl)\(route)")!
            } else {
                return URL(string: "\(baseUrl)\(route)")!
            }
        }
    }

    static private let sessionNoSSLCheck: Session = {
        let manager = ServerTrustManager(evaluators: ["panel.wythyou.com": DisabledTrustEvaluator()])
        let configuration = URLSessionConfiguration.af.default
        return Session(configuration: configuration, serverTrustManager: manager)
    }()

    static private var session: Session {
        StaticConfig.sslVerificationEnabled ?
            AF : sessionNoSSLCheck
    }

    static func performRequest<A: Encodable, R: Decodable>(route: OdooRoute, id: Int?, method: HTTPMethod, arguments: A, retryOnAuthFailed: Bool = true, delegate: @escaping (_ response: R?, _ error: Error?) -> Void) {
        var strRoute = route.rawValue
        if let id = id,
           strRoute.contains(":id") {
            strRoute = strRoute.replacingOccurrences(of: ":id", with: "\(id)")
        }
        let fullUrl = getFullUrl(route: strRoute)
        var headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        if let firebaseToken = User.overrideFirebaseToken {
            headers["Firebase-Token"] = firebaseToken
        } else if let firebaseToken = User.active?.firebaseToken,
                  let expiration = User.active?.firebaseTokenExpiration {
            if expiration.timeIntervalSinceNow < 0 {
                if let user = Auth.auth().currentUser {
                    user.getIDTokenForcingRefresh(true) { newToken, error in
                        if let error = error {
                            delegate(nil, error)
                        } else if let newToken = newToken {
                            User.active?.firebaseToken = newToken
                            User.active?.firebaseTokenExpiration = Date().addingTimeInterval(StaticConfig.firebaseTokenExpiration)
                            performRequest(route: route, id: id, method: method, arguments: arguments, delegate: delegate)
                        } else {
                            // Log out
                            User.active = nil
                            performRequest(route: route, id: id, method: method, arguments: arguments, delegate: delegate)
                        }
                    }
                    return
                }
            } else {
                headers["Firebase-Token"] = firebaseToken
            }
        }
        if let sessionToken = WythYouSession.token {
            headers["X-Openerp"] = sessionToken
            headers["Cookie"] = "session_id=\(sessionToken)"
        }

        print("Request: \(fullUrl)")
        do {
            let dictionary = try arguments.toDictionary()
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            print("Arguments: \(jsonString)")
        } catch {
            print("Error: \(error.localizedDescription)")
        }

        session.request(
            fullUrl,
            method: method,
            parameters: arguments,
            encoder: JSONParameterEncoder.default,
            headers: headers,
            interceptor: nil,
            requestModifier: nil)
            .responseString(completionHandler: { (response: AFDataResponse<String>) in
                print(response)
                if let headers = response.response?.headers,
                    let cookies = headers["Set-Cookie"],
                    !cookies.isEmpty {
                    if let sessionIdCookie = cookies
                            .split(separator: ";")
                            .first(where: { $0.trimmingCharacters(in: .whitespaces).starts(with: "session_id=") }),
                       let sessionId = sessionIdCookie
                               .trimmingCharacters(in: .whitespaces)
                               .split(separator: "=")
                               .last {
                        WythYouSession.token = String(sessionId)
                    }
                }
            })
            .responseDecodable { (response: DataResponse<R, AFError>) in
                if response.response?.statusCode == 401,
                   retryOnAuthFailed,
                   let user = Auth.auth().currentUser {
                    user.getIDTokenForcingRefresh(true) { s, error in
                        if let error = error {
                            DispatchQueue.main.async {
                                delegate(nil, error)
                            }
                        } else if let s = s {
                            User.active?.firebaseToken = s
                            performRequest(route: route, id: id, method: method, arguments: arguments, retryOnAuthFailed: false, delegate: delegate)
                        } else {
                            DispatchQueue.main.async {
                                delegate(response.value, response.error)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        delegate(response.value, response.error)
                    }
                }
            }
    }

    static func performUploadRequest<R: Decodable>(route: OdooRoute, id: Int?, arguments: [String: Any], delegate: @escaping (_ response: R?, _ error: Error?) -> Void) {
        var strRoute = route.rawValue
        if let id = id,
           strRoute.contains(":id") {
            strRoute = strRoute.replacingOccurrences(of: ":id", with: "\(id)")
        }
        let fullUrl = getFullUrl(route: strRoute)
        var headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        if let sessionToken = WythYouSession.token {
            headers["X-Openerp"] = sessionToken
            headers["Cookie"] = "session_id=\(sessionToken)"
        }

        print("Request: \(fullUrl) - multipart")

        session.upload(
            multipartFormData: { multipartFormData in
                for arg in arguments {
                    if let fileWithMetadata = arg.value as? FileWithMetadata {
                        multipartFormData.append(
                            fileWithMetadata.data,
                            withName: arg.key,
                            fileName: fileWithMetadata.fileName ?? "\(arg.key).bin",
                            mimeType: fileWithMetadata.mimeType ?? "application/octet-stream")
                    } else if let data = arg.value as? Data {
                        multipartFormData.append(data, withName: arg.key, fileName: "video.mp4", mimeType: "video/mp4")
                    } else {
                        multipartFormData.append("\(arg.value)".data(using: .utf8)!, withName: arg.key)
                    }
                }
            },
            to: fullUrl)
            .responseString(completionHandler: { (response: AFDataResponse<String>) in
                print(response)
            })
            .responseDecodable { (response: DataResponse<R, AFError>) in
                DispatchQueue.main.async {
                    delegate(response.value, response.error)
                }
            }
    }
}
