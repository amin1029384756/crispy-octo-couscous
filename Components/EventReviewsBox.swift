import UIKit

class EventReviewsBox: UIView {
    lazy var ratingLabel = Label(
        style: .ratingLarge,
        text: "4.5",
        color: Color.titleText,
        lines: 1)

    lazy var rating = Rating(
        starSize: 12,
        distance: 4,
        rating: 4.5,
        isChangeable: false)

    lazy var reviewsLabel = Label(
        style: .normal,
        text: "Reviews (164)",
        color: Color.mainText,
        lines: 1)

    lazy var reviewLine5 = ReviewLine(stars: 5, reviews: 84, totalReviews: 144)

    lazy var reviwewLine4 = ReviewLine(stars: 4, reviews: 20, totalReviews: 144)

    lazy var reviewLine3 = ReviewLine(stars: 3, reviews: 11, totalReviews: 144)

    lazy var reviewLine2 = ReviewLine(stars: 2, reviews: 26, totalReviews: 144)

    lazy var reviewLine1 = ReviewLine(stars: 1, reviews: 3, totalReviews: 144)

    init() {
        super.init(frame: .zero)

        createLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createLayout() {
        addWithConstraints(view: ratingLabel) {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(40)
        }

        addWithConstraints(view: rating) {
            $0.top.equalTo(ratingLabel.snp.top)
            $0.leading.equalTo(ratingLabel.snp.trailing).offset(8)
        }

        addWithConstraints(view: reviewsLabel) {
            $0.bottom.equalTo(ratingLabel.snp.bottom)
            $0.leading.equalTo(ratingLabel.snp.trailing).offset(8)
        }

        addWithConstraints(view: reviewLine5) {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(ratingLabel.snp.bottom).offset(24)
        }

        addWithConstraints(view: reviwewLine4) {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(reviewLine5.snp.bottom).offset(9)
        }

        addWithConstraints(view: reviewLine3) {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(reviwewLine4.snp.bottom).offset(9)
        }

        addWithConstraints(view: reviewLine2) {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(reviewLine3.snp.bottom).offset(9)
        }

        addWithConstraints(view: reviewLine1) {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(reviewLine2.snp.bottom).offset(9)
        }

        var previousView: UIView = reviewLine1

        for _ in 0..<2 {
            let reviewItem = ReviewItem()
            addWithConstraints(view: reviewItem) {
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
                $0.top.equalTo(previousView.snp.bottom).offset(16)
            }
            previousView = reviewItem
        }

        previousView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
        }
    }
}
