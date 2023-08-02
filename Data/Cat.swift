import Foundation

class Cat {
    static var list = [CategoryResponseResult]()

    static func fetch() async throws {
        let response = try await CategoryRequest()
            .performRequest()
        Cat.list = response.result.data ?? []
        Cat.list.sort { cat1, cat2 in
            cat1.id < cat2.id
        }
        for i in Cat.list.indices {
            Cat.list[i].subcategories.sort(by: { scat1, scat2 in
                scat1.order < scat2.order
            })
        }
    }

    static func findSubcategory(id: Int) -> SubcategoryResponseResult? {
        for cat in list {
            if let subCat = cat.subcategories.first(where: { $0.id == id }) {
                return subCat
            }
        }
        return nil
    }
}
