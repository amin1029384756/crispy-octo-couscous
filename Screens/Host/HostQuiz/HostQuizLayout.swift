import UIKit

class HostQuizLayout: Layout {
    lazy var topBar = TopBar(mode: .host, title: "QUIZ", customTopView: nil, delegate: self)

    lazy var titleLabel = Label(
        style: .regular,
        text: "PLEASE ANSWER TO THE FOLLOWING 4 QUESTIONS",
        color: Color.mainText,
        lines: 0)

    lazy var dotProgress = DotProgress(totalDots: QuizQuestion.list.count)

    lazy var questionLabel = Label(
        style: .smallBold,
        text: "",
        color: Color.darkGray,
        lines: 0)

    lazy var answerListView = UIView()

    lazy var bottomBackButton = ShadyBackButton(delegate: self)

    lazy var submitButton = Button(
        style: .green,
        shape: .roundedRectangle(height: 46),
        title: "SUBMIT",
        image: nil,
        delegate: self)

    weak var screen: HostQuizScreen?

    var markedAnswers = Set<Int>()
    var question: QuizQuestion?

    override func createLayout() {
        addWithConstraints(view: topBar) {
            $0.top.equalTo(layoutMarginsGuide.snp.topMargin)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }

        titleLabel.textAlignment = .center
        addWithConstraints(view: titleLabel) {
            $0.top.equalTo(topBar.snp.bottom).offset(44)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        addWithConstraints(view: dotProgress) {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
        }

        addWithConstraints(view: questionLabel) {
            $0.top.equalTo(dotProgress.snp.bottom).offset(48)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
        }

        addWithConstraints(view: answerListView) {
            $0.top.equalTo(questionLabel.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(36)
            $0.trailing.equalToSuperview().offset(-32)
        }

        addWithConstraints(view: bottomBackButton) {
            $0.leading.equalToSuperview().offset(30)
            $0.bottom.equalToSuperview().offset(28)
        }

        addWithConstraints(view: submitButton) {
            $0.bottom.equalTo(bottomBackButton.snp.top).offset(8)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(146)
        }
    }

    func show(question: QuizQuestion, index: Int) {
        questionLabel.text = "\(index+1)- \(question.question)".uppercased()
        dotProgress.show(index: index)
        self.question = question

        let oldViews = answerListView.subviews
        oldViews.forEach {
            $0.removeFromSuperview()
        }

        markedAnswers = Set()
        var previousView: UIView?
        for idx in 0..<question.answers.count {
            let quizAnswerView = QuizAnswerView(
                idx: idx,
                answer: question.answers[idx].answer,
                delegate: self)
            answerListView.addWithConstraints(view: quizAnswerView) {
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
                if let previousView = previousView {
                    $0.top.equalTo(previousView.snp.bottom)
                } else {
                    $0.top.equalToSuperview()
                }
            }
            previousView = quizAnswerView
        }
        previousView?.snp.makeConstraints {
            $0.bottom.equalToSuperview()
        }
    }
}

extension HostQuizLayout: TopBarDelegate {
    func profileButtonClicked() {
        screen?.openProfile()
    }

    func rightButtonClicked() {
        screen?.openEarnings()
    }
}

extension HostQuizLayout: ShadyBackButtonDelegate {
    func backTapped() {
        screen?.goBack()
    }
}

extension HostQuizLayout: ButtonDelegate {
    func buttonClicked(button: Button) {
        switch button {
        case submitButton:
            screen?.submit(answers: markedAnswers)

        default:
            break
        }
    }
}

extension HostQuizLayout: PQuizAnswerViewDelegate {
    func answerSelected(idx: Int) {
        guard let question = question else {
            return
        }

        if question.multiSelection {
            if markedAnswers.contains(idx) {
                markedAnswers.remove(idx)
            } else {
                markedAnswers.insert(idx)
            }
        } else {
            if markedAnswers.contains(idx) {
                // Already selected
                return
            }
            markedAnswers = Set([idx])
        }

        answerListView.subviews.forEach {
            if let quizAnswerView = $0 as? QuizAnswerView {
                quizAnswerView.isSelected = markedAnswers.contains(quizAnswerView.idx)
            }
        }
    }
}
