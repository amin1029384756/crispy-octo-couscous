import UIKit
import Player
import Alamofire

class VideoPreviewScreen: ScreenWithInput<VideoPreviewLayout, URL> {
    var player: Player?

    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self
    }

    override func input(_ argument: URL) {
        loadViewIfNeeded()

        if argument.absoluteString.starts(with: "http") {
            let urlEncoded = argument.absoluteString
                    .filter("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.".contains)

            let destinationString = FileManager.default
                    .urls(for: .cachesDirectory, in: .userDomainMask)[0]
                    .appendingPathComponent(urlEncoded)

            if FileManager.default.fileExists(atPath: destinationString.absoluteString
                    .replacingOccurrences(of: "file://", with: "")) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    self?.runPlayer(url: destinationString)
                }
                return
            }

            let destination: DownloadRequest.Destination = { _, _ in
                (destinationString, [.removePreviousFile])
            }
            loader.show()
            AF.download(argument, to: destination)
                .responseData { [weak self] response in
                    DispatchQueue.main.async { [weak self] in
                        self?.loader.dismiss()
                        self?.runPlayer(url: destinationString)
                    }
                }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.runPlayer(url: argument)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.runPlayer(url: argument)
        }
    }

    func runPlayer(url: URL) {
        player = Player()
        player!.view.frame = view.bounds

        addChild(player!)
        layout.playerContainer.addSubview(player!.view)
        player!.didMove(toParent: self)

        player!.playbackLoops = true
        player!.autoplay = true
        player!.url = url
        player!.fillMode = .resizeAspect

        player!.playFromBeginning()
    }
}
