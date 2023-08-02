import UIKit
import FirebaseAuth
import FirebaseMessaging
import AuthenticationServices

class LoginScreen<L: Layout>: Screen<L>,
    ASAuthorizationControllerPresentationContextProviding,
    ASAuthorizationControllerDelegate {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        view.window!
    }

    private var currentNonce: String?
    private var loggingInRole: UserRole = .guest

    func login(credentials: AuthCredential, role: UserRole, firstName: String, lastName: String) async throws {
        let firebaseAuthResult = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AuthDataResult, Error>) in
            Auth.auth().signIn(with: credentials) { authResult, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let result = authResult {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: ApiError.noFirebaseUser)
                }
            }
        }

        if let newUser = firebaseAuthResult.additionalUserInfo?.isNewUser,
           newUser {
            let profileChangeRequest = firebaseAuthResult.user.createProfileChangeRequest()
            profileChangeRequest.displayName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
            try await profileChangeRequest.commitChanges()
        }

        try await login(
            firebaseUser: firebaseAuthResult.user,
            role: role,
            firstName: firstName,
            lastName: lastName)

        Wylytics.report(event: .LoggedIn(userRole: role))
    }

    func restoreLogin() async throws -> Bool {
        guard let user = Auth.auth().currentUser,
              let role = User.retrieveRole()
        else {
            return false
        }

        let nameParts = (user.displayName ?? "").split(separator: " ")
        let firstName: String
        let lastName: String
        if nameParts.count <= 0 {
            firstName = ""
            lastName = ""
        } else if nameParts.count == 1 {
            firstName = String(nameParts[0])
            lastName = ""
        } else if nameParts.count == 2 {
            firstName = String(nameParts[0])
            lastName = String(nameParts[1])
        } else {
            firstName = nameParts[0...1].joined(separator: " ")
            lastName = nameParts[2...].joined(separator: " ")
        }

        try await login(
            firebaseUser: user,
            role: role,
            firstName: firstName,
            lastName: lastName)

        return true
    }

    func appleSignIn(role: UserRole) {
        loggingInRole = role

        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    func sha256(_ data: Data) -> Data? {
        guard let result = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH)) else { return nil }
        CC_SHA256((data as NSData).bytes, CC_LONG(data.count), result.mutableBytes.assumingMemoryBound(to: UInt8.self))
        return result as Data
    }

    private func sha256(_ input: String) -> String {
        guard
            let data = input.data(using: String.Encoding.utf8),
            let shaData = sha256(data)
        else { return input }
        let hashString = shaData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if length == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func login(firebaseUser: FirebaseAuth.User, role: UserRole, firstName: String, lastName: String) async throws {
        let firebaseToken = try await firebaseUser.getIDToken()

        let response = try await LoginFirebaseRequest(
            uid: firebaseUser.uid,
            token: firebaseToken,
            role: role,
            firstName: firstName,
            lastName: lastName)
            .performRequest()

        guard let apiUser = response.result.data else {
            throw ApiError.missingResponse
        }

        if !apiUser.status {
            throw ApiError.signInError
        }

        User.overrideFirebaseToken = firebaseToken
        defer  {
            User.overrideFirebaseToken = nil
        }

        var profile = apiUser.user
        if (profile == nil) {
            let responseProfile = try await UserViewRequest().performRequest()

            profile = responseProfile.result.data
        }

        guard let profile = profile else {
            throw ApiError.missingResponse
        }

        let fcmToken = try? await Messaging.messaging().token()

        let ktorSignInResponse = try await KtorSignInRequest(
            args: KtorSignInArguments(
                firstName: firstName,
                lastName: lastName,
                isHost: role == .host,
                pushToken: fcmToken
            )
        ).performDataRequest()

        User.active = User(
            uid: apiUser.uid,
            role: role,
            profile: profile,
            firebaseToken: firebaseToken,
            firebaseTokenExpiration: Date().addingTimeInterval(StaticConfig.firebaseTokenExpiration),
            messageLimit: ktorSignInResponse.userInfo.messageLimit,
            messagesUsed: ktorSignInResponse.userInfo.messagesUsed,
            coins: ktorSignInResponse.userInfo.coins,
            coinsUsage: ktorSignInResponse.userInfo.coinsUsage
        )
        CoinForViewsCounter.shared = CoinForViewsCounter()
        User.active?.profile.interests = User.active?.profile.interests?.filter { !$0.isEmpty }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            show(error: "No credential received from Apple")
            return
        }

        guard let nonce = currentNonce else {
            show(error: "Internal error. Nonce was not set")
            return
        }

        guard let appleIDToken = appleIDCredential.identityToken else {
            show(error: "Identity token was not received from Apple")
            return
        }

        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            show(error: "Couldn't convert Apple token to String")
            return
        }

        // Initialize a Firebase credential.
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce)

        loader.showIfNot()
        Task {
            do {
                let firstName = appleIDCredential.fullName?.givenName ?? ""
                let lastName = appleIDCredential.fullName?.familyName ?? ""
                try await login(
                    credentials: credential,
                    role: loggingInRole,
                    firstName: firstName,
                    lastName: lastName)

                await MainActor.run {
                    switch loggingInRole {
                    case .host:
                        navigator.navigate(to: HostPanelScreen.self)

                    case .guest:
                        navigator.navigate(to: GuestHomeScreen.self)
                    }
                }
            } catch {
                await MainActor.run {
                    show(error: error.localizedDescription)
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        loader.dismiss()
        show(error: error.localizedDescription)
    }
}
