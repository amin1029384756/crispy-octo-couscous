import UIKit

class EventCell: UITableViewCell {
    lazy var languageLabel = Label(
        style: .xsmall,
        text: "ENGLISH",
        color: .white,
        lines: 1)

    lazy var photoImageView: OnlineImageView = {
        let imageView = OnlineImageView()
        imageView.backgroundColor = Color.lightGray
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    lazy var nameLabel = Label(
        style: .nameInList,
        text: "JOHN DOE",
        color: Color.nameText,
        lines: 1)

    lazy var rating = Rating(
        type: .userRatingView,
        rating: 0.0)

    lazy var ratingLabel = Label(
        style: .small,
        text: "",
        color: Color.ratingText,
        lines: 1)

    lazy var detailsLabel = Label(
        style: .detailsInList,
        text: "",
        color: Color.detailsText,
        lines: 3)

    lazy var priceLabel = Label(
        style: .experiencePrice,
        text: "$ PER SESSION",
        color: Color.purple,
        lines: 2)

    lazy var durationLabel = Label(
        style: .experiencePrice,
        text: "XX MINS.",
        color: Color.purple,
        lines: 1)

    lazy var card: Card = {
        let cardView = Card()

        cardView.addWithConstraints(view: languageLabel) {
            $0.top.equalToSuperview().offset(2)
            $0.trailing.equalToSuperview().offset(-4)
            $0.width.equalTo(40)
            $0.height.equalTo(16)
        }
        languageLabel.textAlignment = .center
        languageLabel.backgroundColor = Color.purple
        languageLabel.layer.cornerRadius = 8
        languageLabel.layer.masksToBounds = true

        cardView.addWithConstraints(view: photoImageView) {
            $0.top.equalToSuperview().offset(5)
            $0.leading.equalToSuperview().offset(7)
            $0.bottom.equalToSuperview().offset(-5)
            $0.width.equalTo(77)
            $0.height.equalTo(118)
        }

        cardView.addWithConstraints(view: nameLabel) {
            $0.top.equalTo(photoImageView.snp.top)
            $0.leading.equalTo(photoImageView.snp.trailing).offset(18)
            $0.trailing.equalToSuperview().offset(-12)
        }

        cardView.addWithConstraints(view: rating) {
            $0.top.equalTo(nameLabel.snp.bottom)
            $0.leading.equalTo(nameLabel.snp.leading)
        }

        cardView.addWithConstraints(view: ratingLabel) {
            $0.centerY.equalTo(rating.snp.centerY)
            $0.leading.equalTo(rating.snp.trailing).offset(8)
        }

        cardView.addWithConstraints(view: detailsLabel) {
            $0.leading.equalTo(nameLabel.snp.leading)
            $0.top.equalTo(rating.snp.bottom).offset(4)
            $0.trailing.equalToSuperview().offset(-12)
        }

        cardView.addWithConstraints(view: priceLabel) {
            $0.leading.equalTo(nameLabel.snp.leading)
            $0.top.equalTo(detailsLabel.snp.bottom).offset(8)
        }

        cardView.addWithConstraints(view: durationLabel) {
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalTo(priceLabel.snp.centerY)
        }

        return cardView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        createLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createLayout() {
        backgroundColor = .clear
        selectionStyle = .none

        addWithConstraints(view: card) {
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
            $0.top.equalToSuperview().offset(1)
            $0.bottom.equalToSuperview().offset(-8)
            $0.height.equalTo(128)
        }
    }

    func prepare(event: ExperienceIndexResponseResult) {
        nameLabel.text = (event.host ?? event.name).uppercased()
//        rating.set(rating: event.rating)
//        ratingLabel.text = String(format: "(%.01f)", event.rating)
        detailsLabel.text = event.description
        if let subcategory = Cat.findSubcategory(id: event.category_id),
           subcategory.isVideoOnly {
            priceLabel.text = "FREE VLOG\nFREE CHAT"
        } else if let price = event.price {
            priceLabel.text = String(format: "$%.02f PER VIDEO CALL\nFREE CHAT", price)
        } else {
            priceLabel.text = ""
        }
        if let subcategory = Cat.findSubcategory(id: event.category_id),
           subcategory.isVideoOnly {
            durationLabel.text = ""
        } else if let duration = event.duration {
            durationLabel.text = (duration * 60).secondsToString
        } else {
            durationLabel.text = ""
        }
        languageLabel.text = event.language_id.languageName

        if let media = event.medias?.first(where: {
            $0.mimeType.starts(with: "image")
        }) {
            if let key = media.key_s3 {
                let url = "S3://\(StaticConfig.s3Bucket)/public/\(key)"
                photoImageView.set(id: url, expiration: event.expiration)
            } else {
                photoImageView.set(id: media.url, expiration: event.expiration)
            }
        } else if let mimeType = event.video?.mimeType,
           mimeType.starts(with: "image"),
           let url = event.video?.urlFull {
            photoImageView.kf.setImage(with: url)
        } else if let thumbURL = event.video?.thumbnailFull {
            photoImageView.kf.setImage(with: thumbURL)
        } else {
            photoImageView.image = nil
        }
    }
}
