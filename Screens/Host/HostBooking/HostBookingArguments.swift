import Foundation

struct HostBookingArguments {
    var category: CategoryResponseResult
    var subcategory: SubcategoryResponseResult
    var description: String
    var languageId: Int
    var attachedMedias: [FileWithMetadata]
    var hostInfo: HostInfo
}
