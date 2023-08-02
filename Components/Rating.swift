import SnapKit
import UIKit

enum RatingType {
    case userRatingView
    case userRatingLargeView
}

class Rating: UIView {
    lazy var star1Image = Image()
    lazy var star2Image = Image()
    lazy var star3Image = Image()
    lazy var star4Image = Image()
    lazy var star5Image = Image()

    lazy var star1TapDetector = UITapGestureRecognizer(target: self, action: #selector(changeRating(_:)))
    lazy var star2TapDetector = UITapGestureRecognizer(target: self, action: #selector(changeRating(_:)))
    lazy var star3TapDetector = UITapGestureRecognizer(target: self, action: #selector(changeRating(_:)))
    lazy var star4TapDetector = UITapGestureRecognizer(target: self, action: #selector(changeRating(_:)))
    lazy var star5TapDetector = UITapGestureRecognizer(target: self, action: #selector(changeRating(_:)))

    var rating: Double {
        didSet {
            set(rating: rating)
        }
    }

    convenience init(type: RatingType, rating: Double) {
        switch type {
        case .userRatingView:
            self.init(starSize: 8, distance: 0, rating: rating, isChangeable: false)

        case .userRatingLargeView:
            self.init(starSize: 12, distance: 1, rating: rating, isChangeable: false)
        }
    }

    init(starSize: CGFloat, distance: CGFloat, rating: Double, isChangeable: Bool) {
        self.rating = rating

        super.init(frame: .zero)

        addWithConstraints(view: star1Image) {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.width.equalTo(starSize)
            $0.height.equalTo(starSize)
        }

        addWithConstraints(view: star2Image) {
            $0.leading.equalTo(star1Image.snp.trailing).offset(distance)
            $0.top.equalToSuperview()
            $0.width.equalTo(starSize)
            $0.height.equalTo(starSize)
        }

        addWithConstraints(view: star3Image) {
            $0.leading.equalTo(star2Image.snp.trailing).offset(distance)
            $0.top.equalToSuperview()
            $0.width.equalTo(starSize)
            $0.height.equalTo(starSize)
        }

        addWithConstraints(view: star4Image) {
            $0.leading.equalTo(star3Image.snp.trailing).offset(distance)
            $0.top.equalToSuperview()
            $0.width.equalTo(starSize)
            $0.height.equalTo(starSize)
        }

        addWithConstraints(view: star5Image) {
            $0.leading.equalTo(star4Image.snp.trailing).offset(distance)
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.width.equalTo(starSize)
            $0.height.equalTo(starSize)
        }

        snp.makeConstraints {
            $0.height.equalTo(starSize)
        }

        set(rating: rating)

        if isChangeable {
            star1Image.tag = 1
            star1Image.addGestureRecognizer(star1TapDetector)
            star1Image.isUserInteractionEnabled = true

            star2Image.tag = 2
            star2Image.addGestureRecognizer(star2TapDetector)
            star2Image.isUserInteractionEnabled = true

            star3Image.tag = 3
            star3Image.addGestureRecognizer(star3TapDetector)
            star3Image.isUserInteractionEnabled = true

            star4Image.tag = 4
            star4Image.addGestureRecognizer(star4TapDetector)
            star4Image.isUserInteractionEnabled = true

            star5Image.tag = 5
            star5Image.addGestureRecognizer(star5TapDetector)
            star5Image.isUserInteractionEnabled = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func set(rating: Double) {
        let starImages = [
            star1Image,
            star2Image,
            star3Image,
            star4Image,
            star5Image
        ]

        for i in 0..<starImages.count {
            if rating < Double(i) + 0.25 {
                starImages[i].setImage(asset: .starSmallEmpty)
            } else if rating < Double(i) + 0.75 {
                starImages[i].setImage(asset: .starSmallHalf)
            } else {
                starImages[i].setImage(asset: .starSmallFull)
            }
        }
    }

    @objc func changeRating(_ tapDetector: UITapGestureRecognizer) {
        guard let starIdx = tapDetector.view?.tag else {
            return
        }

        rating = Double(starIdx)
    }
}
