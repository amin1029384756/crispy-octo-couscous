import UIKit

class UserTypeSelectorScreen: Screen<UserTypeSelectorLayout> {
    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        clearStack()
    }

    func hostSelected() {
        navigator.navigate(to: HostLoginScreen.self)
    }

    func guestSelected() {
        navigator.navigate(to: GuestLoginScreen.self)
    }
}
