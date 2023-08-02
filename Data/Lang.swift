import Foundation

class Lang {
    static var list = [LanguageResponseResult]()

    static func fetch() async throws {
        let response = try await LanguageRequest()
            .performRequest()
        Lang.list = response.result.data?.sorted { lang1, lang2 in
            lang1.id < lang2.id
        } ?? []
    }
}

extension Int {
    var languageName: String {
        if let language = Lang.list.first(where: {
            $0.id == self
        }) {
            return language.language
        }

        return "Lang \(self)"
    }
}
