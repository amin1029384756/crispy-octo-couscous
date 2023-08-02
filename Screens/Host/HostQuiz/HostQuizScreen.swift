import UIKit

class HostQuizScreen: Screen<HostQuizLayout> {
    var currentStep = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        layout.screen = self

        showStep()
    }

    func showStep() {
        if currentStep >= QuizQuestion.list.count {
            navigator.navigate(to: HostQuizDoneScreen.self)
            return
        }

        let question = QuizQuestion.list[currentStep]
        layout.show(question: question, index: currentStep)
    }

    func submit(answers: Set<Int>) {
        let question = QuizQuestion.list[currentStep]
        if question.multiSelection {
            for answerIdx in 0..<question.answers.count {
                let answer = question.answers[answerIdx]
                if answer.isCorrect,
                   !answers.contains(answerIdx) {
                    show(warning: "Your answer is incorrect. You can choose multiple answers. Please try again")
                    return
                }
                if !answer.isCorrect,
                   answers.contains(answerIdx) {
                    show(warning: "Your answer is incorrect. You can choose multiple answers. Please try again")
                    return
                }
            }
        } else {
            if answers.count != 1 {
                show(warning: "You must select exactly one answer")
                return
            }
            let answerIdx = [Int](answers)[0]
            let answer = question.answers[answerIdx]
            if !answer.isCorrect {
                show(warning: "This answer is incorrect. Please try again")
                return
            }
        }

        currentStep += 1

        showStep()
    }
}
