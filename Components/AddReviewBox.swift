import UIKit

protocol AddReviewBoxDelegate: AnyObject {
    func submit(stars: Int, review: String)
}

class AddReviewBox: UIView {
    weak var delegate: AddReviewBoxDelegate?

    lazy var rateTitleLabel = Label(
        style: .large,
        text: "RATE YOUR EXPERIENCE AFTER YOUR MEETING!",
        color: Color.mainText,
        lines: 0)

    lazy var rateBox: UIView = {
        let view = UIView()
        view.backgroundColor = Color.lightBackground
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true

        view.addWithConstraints(view: rateView) {
            $0.center.equalToSuperview()
        }

        return view
    }()

    lazy var rateView = Rating(starSize: 36, distance: 16, rating: 5, isChangeable: true)

    lazy var reviewBox: UIView = {
        let view = UIView()
        view.layer.borderColor = Color.blueBorder.cgColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 11

        view.addWithConstraints(view: writeReviewLabel) {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
        }

        view.addWithConstraints(view: reviewTextView) {
            $0.top.equalTo(writeReviewLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.bottom.equalToSuperview().offset(-14)
            $0.height.equalTo(86)
        }

        return view
    }()

    lazy var writeReviewLabel = Label(
        style: .large,
        text: "WRITE YOUR EXPERIENCE",
        color: Color.mainLightest,
        lines: 0)

    lazy var reviewTextView = UITextView()

    lazy var submitButton = Button(
        style: .green,
        shape: .roundedRectangle(height: 48),
        title: "SUBMIT",
        image: nil,
        delegate: self)

    init(delegate: AddReviewBoxDelegate?) {
        self.delegate = delegate

        super.init(frame: .zero)

        createLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createLayout() {
        addWithConstraints(view: rateTitleLabel) {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(34)
            $0.trailing.equalToSuperview().offset(-34)
        }

        addWithConstraints(view: rateBox) {
            $0.top.equalTo(rateTitleLabel.snp.bottom).offset(22)
            $0.leading.equalToSuperview().offset(34)
            $0.trailing.equalToSuperview().offset(-34)
            $0.height.equalTo(71)
        }

        addWithConstraints(view: reviewBox) {
            $0.top.equalTo(rateBox.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(34)
            $0.trailing.equalToSuperview().offset(-34)
        }

        addWithConstraints(view: submitButton) {
            $0.top.equalTo(reviewBox.snp.bottom).offset(28)
            $0.leading.equalToSuperview().offset(43)
            $0.trailing.equalToSuperview().offset(-43)
            $0.bottom.equalToSuperview()
        }
    }
}

extension AddReviewBox: ButtonDelegate {
    func buttonClicked(button: Button) {
        guard let reviewText = reviewTextView.text,
              !reviewText.isEmpty
        else {
            return
        }

        delegate?.submit(stars: Int(rateView.rating), review: reviewText)
    }
}
