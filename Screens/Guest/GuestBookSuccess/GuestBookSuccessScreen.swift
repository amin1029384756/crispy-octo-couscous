import UIKit

class GuestBookSuccessScreen: Screen<GuestBookSuccessLayout> {
    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self
    }

    func returnHome() {
        navigationController?.viewControllers
                .compactMap {
                    $0 as? GuestHomeScreen
                }
                .forEach {
                    $0.refresh()
                }
        if !navigator.pop(to: GuestHomeScreen.self) {
            navigator.popToRoot()
        }
    }
}
