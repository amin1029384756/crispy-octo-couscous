import UIKit

class HostAdInProgressScreen: Screen<HostAdInProgressLayout> {
    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self
    }

    func returnToMain() {
        navigationController?.viewControllers
            .compactMap {
                $0 as? HostPanelScreen
            }
            .forEach {
                $0.refresh()
            }
        if !navigator.pop(to: HostPanelScreen.self) {
            navigator.popToRoot()
        }
    }
}
