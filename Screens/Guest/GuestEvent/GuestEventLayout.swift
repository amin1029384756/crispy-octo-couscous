import UIKit
import Player
import Alamofire
import iCarousel
import FirebaseAuth

class GuestEventLayout: Layout {
    weak var screen: GuestEventScreen?

    var selectedDayStart = Date().dateWithoutTime
    var event: ExperienceIndexResponseResult?

    var carouselMedias = [[ExperienceIndexResponseResultMedia]]()

    lazy var topBarBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    lazy var topBar = TopBar(mode: .guest, title: nil, customTopView: chatButton, delegate: self)

    lazy var chatButton = ChatButton(delegate: self)

    lazy var mediaCarousel: iCarousel = {
        let carousel = iCarousel()
        carousel.backgroundColor = .black
        carousel.delegate = self
        carousel.dataSource = self
        carousel.type = .timeMachine
        carousel.isVertical = false
        carousel.bounces = false
        return carousel
    }()

    lazy var mediaPageView: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = UIColor.white
        pageControl.currentPageIndicatorTintColor = Color.main
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()

    lazy var mainScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        scrollView.keyboardDismissMode = .onDrag
        scrollView.delegate = self
        scrollView.addWithConstraints(view: mainScrollableArea) {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
        }
        return scrollView
    }()

    lazy var mainScrollableArea: UIView = {
        let scrollableArea = UIView()

        scrollableArea.addWithConstraints(view: mediaCarousel) {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(400)
        }

        scrollableArea.addWithConstraints(view: mediaPageView) {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(mediaCarousel.snp.bottom).offset(-40)
        }

        scrollableArea.addWithConstraints(view: topBackButton) {
            $0.leading.equalToSuperview().offset(11)
            $0.top.equalToSuperview().offset(310)
        }

        scrollableArea.addWithConstraints(view: mainScrollableContent) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(360)
            $0.bottom.equalToSuperview().offset(44)
        }

        return scrollableArea
    }()

    lazy var mainScrollableContent: UIView = {
        let mainContentView = UIView()
        mainContentView.layer.cornerRadius = 43
        mainContentView.layer.masksToBounds = true
        mainContentView.backgroundColor = .white

        mainContentView.addWithConstraints(view: handlerBar) {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(16)
        }

        mainContentView.addWithConstraints(view: photoImageView) {
            $0.top.equalTo(handlerBar.snp.bottom).offset(10)
            $0.leading.equalTo(34)
            $0.width.equalTo(77)
            $0.height.equalTo(83)
        }

        mainContentView.addWithConstraints(view: nameLabel) {
            $0.top.equalTo(photoImageView.snp.top)
            $0.leading.equalTo(photoImageView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-158)
        }

        mainContentView.addWithConstraints(view: rating) {
            $0.top.equalTo(nameLabel.snp.bottom)
            $0.leading.equalTo(nameLabel.snp.leading)
        }

        mainContentView.addWithConstraints(view: messageMeButton) {
            $0.top.equalTo(photoImageView.snp.top)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(32)
            $0.width.equalTo(128)
        }

        mainContentView.addWithConstraints(view: ratingLabel) {
            $0.centerY.equalTo(rating.snp.centerY)
            $0.leading.equalTo(rating.snp.trailing).offset(8)
        }

        priceLabel.isHidden = true
        mainContentView.addWithConstraints(view: priceLabel) {
            $0.bottom.equalTo(photoImageView.snp.bottom)
            $0.leading.equalTo(nameLabel.snp.leading)
        }

        mainContentView.addWithConstraints(view: durationLabel) {
            $0.bottom.equalTo(photoImageView.snp.bottom).offset(-16)
            $0.trailing.equalToSuperview().offset(-24)
        }

        mainContentView.addWithConstraints(view: languageLabel) {
            $0.top.equalTo(durationLabel.snp.bottom).offset(4)
            $0.trailing.equalTo(durationLabel.snp.trailing)
            $0.width.equalTo(54)
            $0.height.equalTo(21)
        }
        languageLabel.textAlignment = .center
        languageLabel.backgroundColor = Color.purple
        languageLabel.layer.cornerRadius = 10.5
        languageLabel.layer.masksToBounds = true

        mainContentView.addWithConstraints(view: detailsTitleLabel) {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.top.equalTo(languageLabel.snp.bottom).offset(16)
        }

        mainContentView.addWithConstraints(view: detailsLabel) {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.top.equalTo(detailsTitleLabel.snp.bottom).offset(12)
        }

        mainContentView.addWithConstraints(view: hostInfo) {
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.top.equalTo(detailsLabel.snp.bottom).offset(12)
        }

        mainContentView.addWithConstraints(view: bookYourEventLabel) {
            $0.top.equalTo(hostInfo.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(24)
        }

        mainContentView.addWithConstraints(view: selectDayTimeLabel) {
            $0.top.equalTo(bookYourEventLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(24)
        }

        mainContentView.addWithConstraints(view: calendarIcon) {
            $0.top.equalTo(bookYourEventLabel.snp.top).offset(10)
            $0.trailing.equalToSuperview().offset(-46)
        }

        mainContentView.addWithConstraints(view: calendarContainer) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(selectDayTimeLabel.snp.bottom).offset(40)
        }

//        mainContentView.addWithConstraints(view: daySelectionSlider) {
//            $0.leading.equalToSuperview()
//            $0.trailing.equalToSuperview()
//            $0.top.equalTo(calendarContainer.snp.bottom).offset(30)
//        }

        mainContentView.addWithConstraints(view: timeSlotSelector) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(calendarContainer.snp.bottom).offset(30)
        }

        bookNowButton.isEnabled = false
        mainContentView.addWithConstraints(view: bookNowButton) {
            $0.leading.equalToSuperview().offset(43)
            $0.trailing.equalToSuperview().offset(-52)
            $0.top.equalTo(timeSlotSelector.snp.bottom).offset(30)
        }

//        mainContentView.addWithConstraints(view: reviewsLabel) {
//            $0.leading.equalToSuperview().offset(34)
//            $0.trailing.equalToSuperview().offset(-24)
//            $0.top.equalTo(bookNowButton.snp.bottom).offset(44)
//        }
//
//        mainContentView.addWithConstraints(view: addReviewBox) {
//            $0.leading.equalToSuperview()
//            $0.trailing.equalToSuperview()
//            $0.top.equalTo(reviewsLabel.snp.bottom).offset(14)
//        }
//
//        mainContentView.addWithConstraints(view: eventReviewsBox) {
//            $0.leading.equalToSuperview()
//            $0.trailing.equalToSuperview()
//            $0.top.equalTo(addReviewBox.snp.bottom).offset(46)
//        }

        mainContentView.addWithConstraints(view: bottomBackButton) {
//            $0.top.equalTo(eventReviewsBox.snp.bottom)
            $0.top.equalTo(bookNowButton.snp.bottom)
            $0.leading.equalToSuperview().offset(30)
            $0.bottom.equalToSuperview().offset(-20)
        }
        bottomBackButton.transform = CGAffineTransform(translationX: 0, y: 28)

        return mainContentView
    }()

    lazy var topBackButton = ShadyBackButton(delegate: self)

    lazy var handlerBar: UIView = {
        let view = UIView()
        view.backgroundColor = Color.holderBarGray
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.snp.makeConstraints {
            $0.width.equalTo(106)
            $0.height.equalTo(8)
        }
        return view
    }()

    lazy var languageLabel = Label(
        style: .xsmall,
        text: "ENGLISH",
        color: .white,
        lines: 1)

    lazy var photoImageView: OnlineImageView = {
        let imageView = OnlineImageView()
        imageView.backgroundColor = Color.lightGray
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 6
        return imageView
    }()

    lazy var nameLabel = Label(
        style: .nameLarge,
        text: "JOHN DOE",
        color: Color.nameText,
        lines: 1)

    lazy var rating = Rating(
        type: .userRatingLargeView,
        rating: 5.0)

    lazy var messageMeButton = Button(
        style: .green,
        shape: .roundedRectangleWithCorner(corner: 6),
        title: "MESSAGE ME",
        image: .iconChat,
        delegate: self)

    lazy var ratingLabel = Label(
        style: .small,
        text: "",
        color: Color.ratingText,
        lines: 1)

    lazy var detailsTitleLabel = Label(
        style: .sectionTitle,
        text: "DESCRIPTION",
        color: Color.sectionTitle,
        lines: 1)

    lazy var detailsLabel = Label(
        style: .detailsLarge,
        text: "",
        color: Color.detailsText,
        lines: 0)

    lazy var hostInfo = HostInfoView()

    lazy var priceLabel = Label(
        style: .priceLarge,
        text: "$",
        color: Color.purple,
        lines: 1)

    lazy var durationLabel = Label(
        style: .durationLarge,
        text: "XX MINS.",
        color: Color.purple,
        lines: 1)

    lazy var bookYourEventLabel = Label(
        style: .sectionTitle2,
        text: "BOOK YOUR EVENT",
        color: Color.titleText,
        lines: 1)

    lazy var selectDayTimeLabel = Label(
        style: .normal,
        text: "PLEASE SELECT THE DAY AND TIME!",
        color: Color.mainText,
        lines: 1)

    lazy var calendarIcon = Image(
        asset: .iconCalendar,
        tint: Color.mainDark)

    lazy var calendarContainer = UIView()

    var calendarView: CalendarView?

    lazy var timeSlotSelector = TimeSlotSelector(
        timeSlots: [],
        reservedSessions: [],
        canSelect: true,
        canDeleteIfNotReserved: false,
        selectedTimeSlot: screen?.selectedSession?.id,
        delegate: self)

    lazy var bookNowButton = Button(style: .green, shape: .roundedRectangle(height: 48), title: "BOOK NOW!", image: nil, delegate: self)

    lazy var reviewsLabel = Label(
        style: .titleLarge,
        text: "REVIEWS",
        color: Color.titleText,
        lines: 1)

    lazy var addReviewBox = AddReviewBox(delegate: self)

    lazy var eventReviewsBox = EventReviewsBox()

    lazy var bottomBackButton = ShadyBackButton(delegate: self)

    override func createLayout() {
        addWithConstraints(view: mainScrollView) {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        addWithConstraints(view: topBarBackground) {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        addWithConstraints(view: topBar) {
            $0.top.equalTo(layoutMarginsGuide.snp.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(mainScrollView.snp.top)
            $0.bottom.equalTo(topBarBackground.snp.bottom)
        }
    }

    func show(event: ExperienceIndexResponseResult, calendarMonth: Int, calendarYear: Int, selectedDate: Date) {
        selectedDayStart = selectedDate.dateWithoutTime
        self.event = event

        nameLabel.text = (event.host ?? event.name).uppercased()
//        rating.set(rating: event.rating)
//        ratingLabel.text = String(format: "(%.01f)", event.rating)
        detailsLabel.text = event.description
        hostInfo.set(hostInfo: event.hostInfo)
        if let price = event.price {
            priceLabel.text = String(format: "$%.02f", price)
        } else {
            priceLabel.text = ""
        }

        let oldCalendar = calendarContainer.subviews
        oldCalendar.forEach {
            $0.removeFromSuperview()
        }

        if event.isBookingAvailable {
            if let duration = event.duration {
                durationLabel.text = (duration * 60).secondsToString
            } else {
                durationLabel.text = ""
            }

            calendarView = CalendarView(
                month: calendarMonth,
                year: calendarYear,
                selectedDate: selectedDayStart,
                datesWithSlots: event.sessions?
                    .filter {
                        !$0.isFull
                    }
                    .compactMap {
                        $0.getStartDateTime()
                    } ?? [],
                delegate: self
            )

            calendarContainer.addWithConstraints(view: calendarView!) {
                $0.edges.equalToSuperview()
            }

            timeSlotSelector.set(
                timeSlots: event.sessions?.filter {
                    $0.getStartDateTime()?.dateWithoutTime == selectedDayStart
                } ?? [],
                selectedTimeSlot: screen?.selectedSession?.id
            )

            bookYourEventLabel.isHidden = false
            selectDayTimeLabel.isHidden = false
            calendarIcon.isHidden = false
            bookNowButton.isHidden = false
        } else {
            durationLabel.text = ""

            timeSlotSelector.set(timeSlots: [], selectedTimeSlot: nil)

            bookYourEventLabel.isHidden = true
            selectDayTimeLabel.isHidden = true
            calendarIcon.isHidden = true
            bookNowButton.isHidden = true
        }

        var iconUrl: String?
        if let mediaIcon = event.medias?.first(where: {
            $0.mimeType.starts(with: "image")
        }) {
            if let key = mediaIcon.key_s3 {
                let url = "S3://\(StaticConfig.s3Bucket)/public/\(key)"
                iconUrl = url
            } else {
                iconUrl = mediaIcon.url
            }
        }
        if let video = event.video {
            if let mimeType = video.mimeType,
               mimeType.starts(with: "image"),
               let thumbnailURL = video.urlFull {
                if iconUrl == nil {
                    iconUrl = thumbnailURL.absoluteString
                }
            } else  {
                if let thumbnailURL = video.thumbnailFull {
                    if iconUrl == nil {
                        iconUrl = thumbnailURL.absoluteString
                    }
                }
            }
        }

        carouselMedias.removeAll()

        if let medias = event.medias,
           !medias.isEmpty {
            for media in medias {
                if media.isThumb { continue }
                if media.mimeType.starts(with: "video") {
                    if let thumb = medias.first(where: { $0.fileName == media.fileName + ".thumb.jpg" }) {
                        carouselMedias.append([media, thumb])
                    } else {
                        carouselMedias.append([media])
                    }
                } else if media.mimeType.starts(with: "image") {
                    carouselMedias.append([media])
                }
            }
        } else if let video = event.video,
                  let url = video.urlFull {
            carouselMedias.append([
                ExperienceIndexResponseResultMedia(
                    id: video.id,
                    fileName: "image.jpg",
                    mimeType: video.mimeType ?? "image/jpeg",
                    url: url.absoluteString
                )
            ])
        }

        mediaCarousel.reloadData()
        mediaPageView.numberOfPages = carouselMedias.count
        mediaPageView.currentPage = 0

        if let iconUrl = iconUrl {
            photoImageView.set(id: iconUrl, expiration: event.expiration)
        }
        layoutIfNeeded()
    }
}

extension GuestEventLayout: TopBarDelegate {
    func profileButtonClicked() {
        screen?.openProfile()
    }

    func rightButtonClicked() {
        screen?.openWallet()
    }
}

extension GuestEventLayout: CalendarDelegate {
    func daySelectedInCalendar(date: Date) {
        screen?.selectedSession = nil
        selectedDayStart = date.dateWithoutTime

        timeSlotSelector.set(
            timeSlots: event?.sessions?.filter {
                $0.getStartDateTime()?.dateWithoutTime == selectedDayStart
            } ?? [],
            selectedTimeSlot: screen?.selectedSession?.id
        )
    }
}

extension GuestEventLayout: GuestEventMediaViewDelegate {
    func openMedia() {
        if mediaCarousel.currentItemIndex >= carouselMedias.count {
            return
        }
        let medias = carouselMedias[mediaCarousel.currentItemIndex]
        screen?.preview(medias: medias)
    }
}

extension GuestEventLayout: TimeSlotSelectorDelegate {
    func timeSlotDeleted(id: Int) {
        // Not available here
    }

    func timeSlotDeleted(date: Date) {
        // Not available here
    }

    func timeSlotSelected(timeSlot: SessionResponseResult) {
        screen?.selectedSession = timeSlot
    }
}

extension GuestEventLayout: ButtonDelegate {
    func buttonClicked(button: Button) {
        switch button {
        case bookNowButton:
            screen?.makeBooking()

        case chatButton, messageMeButton:
            screen?.startChat()

        default:
            break
        }
    }
}

extension GuestEventLayout: AddReviewBoxDelegate {
    func submit(stars: Int, review: String) {
        screen?.submit(stars: stars, review: review)
    }
}

extension GuestEventLayout: ShadyBackButtonDelegate {
    func backTapped() {
        screen?.goBack()
    }
}

extension GuestEventLayout: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        mediaCarousel.transform = CGAffineTransform(translationX: 0, y: scrollView.contentOffset.y/2)
    }
}

extension GuestEventLayout: iCarouselDataSource, iCarouselDelegate {
    func numberOfItems(in carousel: iCarousel) -> Int {
        carouselMedias.count
    }

    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var mediaView: GuestEventMediaView
        if let view = view as? GuestEventMediaView {
            mediaView = view
            mediaView.set(medias: carouselMedias[index], expiration: event?.expiration)
        } else {
            mediaView = GuestEventMediaView(
                medias: carouselMedias[index],
                expiration: event?.expiration,
                delegate: self
            )
        }
        return mediaView
    }

    open func carouselItemWidth(_ carousel: iCarousel) -> CGFloat {
        UIScreen.main.bounds.width
    }

    open func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
        case .wrap:
            return 0.0

        case .spacing:
            return 0.0

        default:
            return value
        }
    }

    open func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        let index = carousel.currentItemIndex
        mediaPageView.currentPage = index
    }
}

extension GuestEventLayout: ChatButtonDelegate {
    func openChatList() {
        screen?.openChatList()
    }
}
