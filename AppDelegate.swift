import UIKit
import GoogleSignIn
import FirebaseCore
import Amplify
import AmplifyPlugins
import FBSDKCoreKit
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    static var signInConfig: GIDConfiguration!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        Messaging.messaging().delegate = self

        AppDelegate.signInConfig = GIDConfiguration(
            clientID: ApiKeys.googleClientID
        )

        initializePayPal()

        Wylytics.initialize()

        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.configure()
            print("Amplify configured with storage plugin")
        } catch {
            print(error)
        }

        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        requestNotificationsPermission(application: application)

        return true
    }

    func requestNotificationsPermission(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var handled: Bool

        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }

        handled = ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        if handled {
            return true
        }

        // Handle other custom URL types.

        // If not handled by this app, return false.
        return false
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate { }

extension AppDelegate: MessagingDelegate {
  // [START refresh_token]
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("Firebase registration token: \(String(describing: fcmToken))")

    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
  }

  // [END refresh_token]
}
