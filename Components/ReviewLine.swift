import UIKit
import SnapKit

class ReviewLine: UIView {
    let stars: Int
    var reviews: Int
    var totalReviews: Int

    var activeLineWidth: ConstraintMakerEditable!

    var starsView: Rating!

    lazy var lineBackground: UIView = {
        let view = UIView()
        view.backgroundColor = Color.lightGray
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true

        view.addWithConstraints(view: lineActive) {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            activeLineWidth = $0.width.equalTo(1)
        }

        return view
    }()

    lazy var lineActive: UIView = {
        let view = UIView()
        view.backgroundColor = Color.mainDark
        return view
    }()

    lazy var countLabel = Label(
        style: .normal,
        text: "0",
        color: Color.mainText,
        lines: 1)

    init(stars: Int, reviews: Int, totalReviews: Int) {
        self.stars = stars
        self.reviews = reviews
        self.totalReviews = totalReviews

        super.init(frame: .zero)

        createLayout()
        showValues()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createLayout() {
        starsView = Rating(
            starSize: 12,
            distance: 4,
            rating: Double(stars),
            isChangeable: false)

        addWithConstraints(view: starsView) {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }

        addWithConstraints(view: lineBackground) {
            $0.leading.equalTo(starsView.snp.trailing).offset(14)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(4)
        }

        countLabel.textAlignment = .right
        addWithConstraints(view: countLabel) {
            $0.leading.equalTo(lineBackground.snp.trailing).offset(8)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(30)
        }

        snp.makeConstraints {
            $0.height.equalTo(20)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        showValues()
    }

    func showValues() {
        countLabel.text = "\(reviews)"

        activeLineWidth.constraint.update(
            offset: lineBackground.bounds.width * CGFloat(reviews) / CGFloat(totalReviews)
        )

        super.layoutSubviews()
    }
}
