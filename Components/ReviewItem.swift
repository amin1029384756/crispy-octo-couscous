import UIKit
import Kingfisher

class ReviewItem: UIView {
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 22
        imageView.layer.masksToBounds = true

        imageView.snp.makeConstraints {
            $0.width.equalTo(44)
            $0.height.equalTo(44)
        }

        return imageView
    }()

    lazy var nameLabel = Label(
        style: .sectionTitle,
        text: "Hossein Zarghami",
        color: Color.darkText,
        lines: 1)

    lazy var timeLabel = Label(
        style: .normal,
        text: "1 day",
        color: Color.mainText,
        lines: 1)

    lazy var stars = Rating(
        starSize: 12,
        distance: 4,
        rating: 5.0,
        isChangeable: false)

    lazy var commentLabel = Label(
        style: .small,
        text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Donec ultrices tincidunt arcu non sodales.\n" +
        "Tellus in metus vulputate eu. Interdum posuere lorem ipsum dolor sit amet consectetur. Nulla pharetra diam sit amet ",
        color: .darkText,
        lines: 0)

    init() {
        super.init(frame: .zero)

        createLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createLayout() {
        avatarImageView.kf.setImage(with: URL(string: "https://i.pravatar.cc/132"))
        addWithConstraints(view: avatarImageView) {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview()
        }

        addWithConstraints(view: nameLabel) {
            $0.leading.equalTo(avatarImageView.snp.trailing).offset(8)
            $0.top.equalTo(avatarImageView.snp.top).offset(10)
        }

        addWithConstraints(view: timeLabel) {
            $0.leading.equalTo(nameLabel.snp.leading)
            $0.top.equalTo(nameLabel.snp.bottom)
        }

        addWithConstraints(view: stars) {
            $0.leading.equalTo(nameLabel.snp.trailing).offset(8)
            $0.leading.equalTo(timeLabel.snp.trailing).offset(8)
            $0.top.equalTo(nameLabel.snp.top)
            $0.trailing.equalToSuperview().offset(-24)
        }

        addWithConstraints(view: commentLabel) {
            $0.leading.equalTo(nameLabel.snp.leading)
            $0.top.equalTo(timeLabel.snp.bottom).offset(16)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview()
        }
    }
}
