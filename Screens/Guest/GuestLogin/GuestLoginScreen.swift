import UIKit
import GoogleSignIn
import FirebaseAuth

class GuestLoginScreen: LoginScreen<GuestLoginLayout> {
    var isAgreed = false

    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self
    }

    func startGoogleLogin() {
        if (!isAgreed) {
            show(warning: "You need to agree to our privacy policy before you start")
            return
        }

        GIDSignIn.sharedInstance.signIn(
            with: AppDelegate.signInConfig,
            presenting: self) { [weak self] user, error in
                if let user = user,
                   error == nil,
                   let token = user.authentication.idToken {
                    let credential = GoogleAuthProvider.credential(withIDToken: token,
                        accessToken: user.authentication.accessToken)

                    Task {
                        do {
                            let firstName = user.profile?.givenName ?? ""
                            let lastName = user.profile?.familyName ?? ""
                            try await self?.login(
                                credentials: credential,
                                role: .guest,
                                firstName: firstName,
                                lastName: lastName
                            )
                            await MainActor.run {
                                self?.navigator.navigate(to: GuestHomeScreen.self)
                            }
                        } catch {
                            _ = try? Auth.auth().signOut()
                            GIDSignIn.sharedInstance.signOut()
                            await MainActor.run {
                                self?.show(error: error.localizedDescription)
                            }
                        }
                    }
                } else if let error = error {
                    self?.show(error: error.localizedDescription)
                } else {
                    self?.show(error: "Google sign in returned error")
                }
            }
    }

    func lookAround() {
        navigator.navigate(to: GuestHomeScreen.self)
    }

    func startAppleLogin() {
        if (!isAgreed) {
            show(warning: "You need to agree to our privacy policy before you start")
            return
        }

        appleSignIn(role: .guest)
    }
}
