import UIKit
import GoogleSignIn
import FirebaseRemoteConfig
import FirebaseAuth

class SplashScreen: LoginScreen<SplashLayout> {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        fetchConfig()
    }

    private func fetchConfig() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.fetchAndActivate { [weak self] (status, error) in
            if let interviewLink = remoteConfig.configValue(forKey: "interviewLink").stringValue,
               let interviewLinkUrl = URL(string: interviewLink) {
                URLs.interviewLink = interviewLinkUrl
            }
            if let minVersion = remoteConfig.configValue(forKey: "minVersion").stringValue,
               let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                if appVersion.checkAppVersion(minVersion: minVersion) {
                    self?.authenticate()
                } else {
                    self?.showUpdatePopup()
                }
            } else {
                self?.authenticate()
            }
        }
    }

    private func showUpdatePopup() {
        let alert = UIAlertController(title: "App needs an update", message: "We updated the app and included some critical changes. You need to update it to continue", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Update now", style: .default) { _ in
            URLs.appStore.openInExternalBrowser()
        })
        alert.addAction(UIAlertAction(title: "Quit", style: .cancel) { _ in
            exit(0)
        })
        present(alert, animated: true)
    }

    private func authenticate() {
        AuthenticateRequest(login: OdooCreds.login, password: OdooCreds.password)
            .performRequestWithDelegate { [weak self] response, error in
                Task {
                    self?.loadData()
                }
        }
    }

    private func loadData() async {
        _ = try? await Lang.fetch()
        _ = try? await Cat.fetch()
        await checkIfLoggedIn()
    }

    private func loginRestored() async {
        await MainActor.run {
            switch User.active?.role ?? .guest {
            case .host:
                navigator.navigate(to: HostPanelScreen.self)

            case .guest:
                navigator.navigate(to: GuestHomeScreen.self)
            }
        }
    }

    private func signOutAndRoute() async {
        await MainActor.run {
            _ = try? Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            navigator.navigate(to: UserTypeSelectorScreen.self)
        }
    }

    private func checkIfLoggedIn() async {
        do {
            let restoreSuccess = try await restoreLogin()
            if restoreSuccess {
                await loginRestored()
            } else {
                await signOutAndRoute()
            }
        } catch {
            await signOutAndRoute()
        }
    }
}
