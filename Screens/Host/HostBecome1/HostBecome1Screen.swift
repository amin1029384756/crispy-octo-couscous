import UIKit

class HostBecome1Screen: Screen<HostBecome1Layout> {
    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self
    }

    func goNext() {
        navigator.navigate(to: HostBecome2Screen.self)
    }
}
