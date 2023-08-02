import UIKit

protocol HostPanelExperienceViewDelegate: AnyObject {
    func edit(experience: ExperienceIndexResponseResult)
    func share(experience: ExperienceIndexResponseResult)
    func delete(experience: ExperienceIndexResponseResult)
}

class HostPanelExperienceView: UIView {
    weak var delegate: HostPanelExperienceViewDelegate?
    var experience: ExperienceIndexResponseResult?
    let isReady: Bool

    init(experience: ExperienceIndexResponseResult?, delegate: HostPanelExperienceViewDelegate?, isReady: Bool) {
        self.isReady = isReady

        super.init(frame: .zero)

        createLayout()

        if let experience = experience {
            set(experience: experience, thumb: nil, delegate: delegate)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.backgroundColor = .black

        view.addWithConstraints(view: backgroundImageView) {
            $0.edges.equalToSuperview()
        }

        view.addWithConstraints(view: whiteShade) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        view.addWithConstraints(view: languageLabel) {
            $0.top.equalTo(whiteShade.snp.top).offset(-8)
            $0.trailing.equalToSuperview().offset(-12)
            $0.width.equalTo(40)
            $0.height.equalTo(16)
        }
        languageLabel.textAlignment = .center
        languageLabel.backgroundColor = Color.purple
        languageLabel.layer.cornerRadius = 8
        languageLabel.layer.masksToBounds = true

        view.addWithConstraints(view: serviceIconFrame) {
            $0.top.equalTo(whiteShade.snp.top).offset(-16)
            $0.leading.equalToSuperview().offset(12)
        }

        return view
    }()

    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var whiteShade: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.93)
        view.layer.cornerRadius = 15

        view.addWithConstraints(view: experienceNameLabel) {
            $0.top.equalToSuperview().offset(32)
            $0.leading.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-14)
        }

        view.addWithConstraints(view: durationLabel) {
            $0.top.equalTo(experienceNameLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(14)
        }

        view.addWithConstraints(view: priceLabel) {
            $0.centerY.equalTo(durationLabel.snp.centerY)
            $0.trailing.equalToSuperview().offset(-14)
        }

        view.addWithConstraints(view: descriptionLabel) {
            $0.top.equalTo(durationLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-14)
            $0.bottom.equalToSuperview().offset(-96)
        }

        if isReady {
            view.addWithConstraints(view: deleteButton) {
                $0.bottom.equalToSuperview().offset(-8)
                $0.trailing.equalToSuperview().offset(-14)
                $0.width.equalTo(64)
            }

//            view.addWithConstraints(view: shareButton) {
//                $0.bottom.equalTo(deleteButton.snp.top).offset(-5)
//                $0.trailing.equalToSuperview().offset(-14)
//                $0.width.equalTo(64)
//            }

            view.addWithConstraints(view: editButton) {
//                $0.bottom.equalTo(shareButton.snp.top).offset(-5)
                $0.bottom.equalTo(deleteButton.snp.top).offset(-5)
                $0.trailing.equalToSuperview().offset(-14)
                $0.width.equalTo(64)
            }
        } else {
            view.addWithConstraints(view: editButton) {
                $0.bottom.equalToSuperview().offset(-8)
                $0.trailing.equalToSuperview().offset(-14)
                $0.width.equalTo(64)
            }
        }

        return view
    }()

    private lazy var serviceIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var serviceIconFrame: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2
        view.layer.backgroundColor = Color.purple.cgColor
        view.layer.cornerRadius = 16

        view.snp.makeConstraints {
            $0.width.equalTo(32)
            $0.height.equalTo(32)
        }

        view.addWithConstraints(view: serviceIcon) {
            $0.width.equalTo(24)
            $0.height.equalTo(24)
            $0.center.equalToSuperview()
        }
        return view
    }()

    private lazy var languageLabel = Label(
        style: .xsmall,
        text: "ENGLISH",
        color: .white,
        lines: 1)

    private lazy var experienceNameLabel = Label(
        style: .normal,
        text: "EXPERIENCE",
        color: Color.mainText,
        lines: 1)

    private lazy var durationLabel = Label(
        style: .small,
        text: "DURATION",
        color: Color.mainText,
        lines: 1)

    private lazy var priceLabel = Label(
        style: .experiencePriceBig,
        text: "$",
        color: Color.mainText,
        lines: 1)

    private lazy var descriptionLabel = Label(
        style: .normal,
        text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Luctus venenatis lectus magna fringilla urna.\n\n",
        color: Color.mainText,
        lines: 5)

    private lazy var editButton = Button(
        style: .green,
        shape: .roundedRectangle(height: 23),
        title: "EDIT",
        image: nil,
        delegate: self)

    private lazy var shareButton = Button(
        style: .greenOutline,
        shape: .roundedRectangle(height: 23),
        title: "SHARE",
        image: nil,
        delegate: self)

    private lazy var deleteButton = Button(
        style: .darkGreen,
        shape: .roundedRectangle(height: 23),
        title: "DELETE",
        image: nil,
        delegate: self)

    private func createLayout() {
        backgroundColor = .clear

        addWithConstraints(view: containerView) {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(31)
            $0.trailing.equalToSuperview().offset(-31)
        }
    }

    func set(experience: ExperienceIndexResponseResult, thumb: UIImage?, delegate: HostPanelExperienceViewDelegate?) {
        self.experience = experience
        self.delegate = delegate
        let subcategory = Cat.findSubcategory(id: experience.category_id)
        languageLabel.text = experience.language_id.languageName
        experienceNameLabel.text = experience.name
        if let subcategory = subcategory,
           subcategory.isVideoOnly {
            durationLabel.text = ""
        } else if let duration = experience.duration {
            durationLabel.text = (duration * 60).secondsToString
        } else {
            durationLabel.text = ""
        }
        if let subcategory = subcategory,
           subcategory.isVideoOnly {
            priceLabel.text = ""
        } else if let price = experience.price {
            priceLabel.text = String(format: "$%.02f", price)
        } else {
            priceLabel.text = ""
        }
        descriptionLabel.text = experience.description
        if let subCategory = Cat.findSubcategory(id: experience.category_id) {
            serviceIcon.image = subCategory.icon.base64Image
        } else {
            serviceIcon.image = nil
        }
        if let thumb = thumb {
            backgroundImageView.image = thumb
        } else if let medias = experience.medias,
                  !medias.isEmpty,
                  let imageMedia = medias.first(where: {
                      $0.mimeType.starts(with: "image")
                  }),
                  let url = URL(string: imageMedia.url) {
            backgroundImageView.kf.setImage(with: url)
        } else if let video = experience.video {
            if video.mimeType?.starts(with: "image") == true,
               let url = video.urlFull {
                backgroundImageView.kf.setImage(with: url)
            } else {
                backgroundImageView.image = experience.video?.thumbnail?.base64Image
            }
        }

    }
}

extension HostPanelExperienceView: ButtonDelegate {
    func buttonClicked(button: Button) {
        guard let experience = experience else {
            return
        }

        switch button {
        case editButton:
            delegate?.edit(experience: experience)

        case shareButton:
            delegate?.share(experience: experience)

        case deleteButton:
            delegate?.delete(experience: experience)

        default:
            break
        }
    }
}
