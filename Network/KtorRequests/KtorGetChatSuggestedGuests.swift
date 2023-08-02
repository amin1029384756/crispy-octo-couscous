import Alamofire

class KtorGetChatSuggestedGuestsRequest: KtorBaseRequest<KtorBaseEmpty, [KtorGetChatSuggestedGuestsResponse]> {
    init() {
        super.init()
    }

    override var route: KtorRoute {
        .chatsSuggestedGuests
    }

    override var method: HTTPMethod {
        .get
    }
}

struct KtorGetChatSuggestedGuestsResponse: Decodable {
    let id: Int
    let uid: String
    let name: String
    let profilePicture: String?
    let registrationDate: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case uid
        case name
        case profilePicture
        case registrationDate
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        uid = try values.decode(String.self, forKey: .uid)
        name = try values.decode(String.self, forKey: .name)
        profilePicture = try? values.decode(String?.self, forKey: .profilePicture)
        if let registrationDateString = try? values.decode(String.self, forKey: .registrationDate) {
            registrationDate = KtorGetChatSuggestedGuestsResponse.dateFormatter.date(from: registrationDateString)
        } else {
            registrationDate = nil
        }
    }

    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter
    }()
}
