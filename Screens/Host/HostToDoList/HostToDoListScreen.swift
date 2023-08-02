import UIKit

class HostToDoListScreen: Screen<HostToDoListLayout> {
    var youTubeWatched = false

    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self
    }

    func goNext() {
        if youTubeWatched {
            navigator.navigate(to: HostQuizScreen.self)
        } else {
            showYouTubeVideo()
        }
    }

    func showYouTubeVideo() {
        youTubeWatched = true
        URLs.hostYouTubeVideo.openInExternalBrowser()
    }

    func scheduleInterview() {
        URLs.interviewLink.openInExternalBrowser()
    }
}
