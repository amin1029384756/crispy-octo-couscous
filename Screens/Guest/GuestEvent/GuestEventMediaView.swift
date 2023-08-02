import UIKit
import SnapKit

protocol GuestEventMediaViewDelegate: AnyObject {
    func openMedia()
}

class GuestEventMediaView: UIView {
    weak var delegate: GuestEventMediaViewDelegate?

    lazy var blurryImageView: OnlineImageView = {
        let imageView = OnlineImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    lazy var blurView: UIView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        return blurEffectView
    }()

    lazy var topImageView: OnlineImageView = {
        let imageView = OnlineImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var playButton: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .center
        imageView.image = ImageAsset.playVideo.image
        return imageView
    }()

    lazy var showButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(" ", for: .normal)
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        return button
    }()

    init(medias: [ExperienceIndexResponseResultMedia], expiration: Date?, delegate: GuestEventMediaViewDelegate?) {
        let screenWidth = UIScreen.main.bounds.width

        super.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 400))

        self.delegate = delegate

        backgroundColor = .black
        layer.masksToBounds = true

        addSubview(blurryImageView)
        blurryImageView.frame = CGRect(x: 0, y: -20, width: screenWidth, height: 420)

        addSubview(blurView)
        blurView.frame = CGRect(x: 0, y: -20, width: screenWidth, height: 420)

        addSubview(topImageView)
        topImageView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 380)

        addSubview(playButton)
        playButton.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 370)

        addSubview(showButton)
        showButton.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 380)

        set(medias: medias, expiration: expiration)
    }

    func set(medias: [ExperienceIndexResponseResultMedia], expiration: Date?) {
        if let imageMedia = medias.first(where: { $0.mimeType.starts(with: "image") }) {
            if let key = imageMedia.key_s3 {
                let url = "S3://\(StaticConfig.s3Bucket)/public/\(key)"
                blurryImageView.set(id: url, expiration: expiration) { [weak self] _ in
                    self?.topImageView.set(id: url, expiration: expiration)
                }
            } else {
                blurryImageView.set(id: imageMedia.url, expiration: expiration) { [weak self] _ in
                    self?.topImageView.set(id: imageMedia.url, expiration: expiration)
                }
            }
        }

        playButton.isHidden = !medias.contains(where: { $0.mimeType.starts(with: "video") })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func tapped() {
        delegate?.openMedia()
    }
}
