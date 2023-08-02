import Foundation
import Amplify
import AmplifyPlugins

enum ExperienceIndexType {
    case host
    case guest
}

struct ExperienceIndexRequestParams: Encodable {
}

class ExperienceIndexRequest: BaseRequest<ExperienceIndexRequestParams, ExperienceIndexResponse> {
    var type: ExperienceIndexType

    init(type: ExperienceIndexType) {
        self.type = type

        super.init(
            params: ExperienceIndexRequestParams()
        )
    }

    override var route: OdooRoute {
        switch type {
        case .guest:
            #if DEBUG
            if StaticConfig.showAllExperienceInDebugMode {
                return .experienceGuestIndexDebug
            }
            #endif
            return .experienceGuestIndex

        case .host:
            return .experienceHostIndex
        }
    }
}

struct ExperienceIndexResponseResultVideo: Decodable {
    var id: Int
    var mimeType: String?
    var url: String?
    var thumbnail: String?

    var thumbnailFull: URL? {
        guard let thumbnail = thumbnail else { return nil }
        if thumbnail.isEmpty {
            return nil
        } else {
            return NetworkOdoo.getFullUrl(route: thumbnail)
        }
    }

    var urlFull: URL? {
        guard let url = url else { return nil }
        if url.isEmpty {
            return nil
        } else {
            return NetworkOdoo.getFullUrl(route: url)
        }
    }
}

struct ExperienceIndexResponseResultMedia: Decodable {
    var id: Int
    var fileName: String
    var mimeType: String
    var url: String
    var key_s3: String?

    var isThumb: Bool {
        fileName.contains(".thumb.")
    }

    mutating func resolveUrl() async throws {
        guard let keyS3 = key_s3 else { return }

        self.url = try await withCheckedThrowingContinuation { continuation in
            Amplify.Storage.getURL(key: keyS3) { event in
                switch event {
                case let .success(url):
                    continuation.resume(returning: url.absoluteString)

                case let .failure(storageError):
                    continuation.resume(throwing: storageError)
                }
            }
        }
    }
}

struct ExperienceIndexResponseResult: Decodable {
    var id: Int
    var name: String
    var user_id: Int
    var language_id: Int
    var duration: Int?
    var price: Double?
    var status: String?
    var shareUrl: String?
    var description: String?
    var category_id: Int
    var host: String?
    var host_uid: String?
    var video: ExperienceIndexResponseResultVideo?
    var sessions: [SessionResponseResult]?
    var medias: [ExperienceIndexResponseResultMedia]?
    var hostInfo: HostInfo?

    init(id: Int, name: String, user_id: Int,
         language_id: Int, category_id: Int) {
        self.id = id
        self.name = name
        self.user_id = user_id
        self.language_id = language_id
        self.category_id = category_id
    }

    var expiration: Date? {
        let endDates: [Date] = (sessions ?? [])
            .compactMap { $0.getEndDateTime() }
        return endDates.max()
    }

    var isBookingAvailable: Bool {
        if let subcategory = Cat.findSubcategory(id: category_id) {
            return subcategory.isBookingAvailable
        } else {
            return false
        }
    }
}

class ExperienceIndexResponse: BaseDataResponse<[ExperienceIndexResponseResult]> {
}
