extension User {
    func loadProfile() async throws {
        let profileResponse = try await UserViewRequest()
            .performRequest()
        if let profile = profileResponse.result.data {
            User.active?.profile = profile
        }
    }

    func loadProfile(delegate: @escaping (_ error: Error?) -> Void) {
        UserViewRequest()
            .performRequestWithDelegate { responseProfile, errorProfile in
            if let error = errorProfile {
                delegate(error)
            } else {
                if let profile = responseProfile?.result.data {
                    User.active?.profile = profile
                }
                delegate(nil)
            }
        }
    }
}
