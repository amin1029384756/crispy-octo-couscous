import Foundation

struct QuizQuestion {
    struct QuizAnswer {
        var answer: String
        var isCorrect: Bool
    }

    var id: Int
    var question: String
    var answers: [QuizAnswer]
    var multiSelection: Bool = false

    static let list = [
        QuizQuestion(
            id: 1,
            question: "How should you respond when one shares their struggles with you?",
            answers: [
                QuizAnswer(
                    answer: "Provide solutions to their problems",
                    isCorrect: false
                ),
                QuizAnswer(
                    answer: "Honor their struggles",
                    isCorrect: true
                ),
                QuizAnswer(
                    answer: "Analyze their decisions in life",
                    isCorrect: false
                ),
                QuizAnswer(
                    answer: "Be indifferent",
                    isCorrect: false
                )
            ]
        ),
        QuizQuestion(
            id: 2,
            question: "One way to project positive energy is to take enthusiastic interest in others. Select the questions below that can help you achieve this: (Select All that Apply)",
            answers: [
                QuizAnswer(
                    answer: "Ask about their interests",
                    isCorrect: true
                ),
                QuizAnswer(
                    answer: "Ask about their desires",
                    isCorrect: true
                ),
                QuizAnswer(
                    answer: "Ask about their fears",
                    isCorrect: true
                ),
                QuizAnswer(
                    answer: "Ask about their dreams",
                    isCorrect: true
                )
            ],
            multiSelection: true
        ),
        QuizQuestion(
            id: 3,
            question: "What is the third principle discussed in the video?",
            answers: [
                QuizAnswer(
                    answer: "Emotions are contagious; Don’t mirror bad energy",
                    isCorrect: true
                ),
                QuizAnswer(
                    answer: "Think deeply to find solutions to struggles in life",
                    isCorrect: false
                ),
                QuizAnswer(
                    answer: "Be confident in your interactions with others",
                    isCorrect: false
                )
            ]
        ),
        QuizQuestion(
            id: 4,
            question: "As discussed in the video, how can you send well wishes to others without talking?",
            answers: [
                QuizAnswer(
                    answer: "You always have to vocalize your good thoughts to project positive energy",
                    isCorrect: false
                ),
                QuizAnswer(
                    answer: "Send the user a note offline and after your meeting",
                    isCorrect: false
                ),
                QuizAnswer(
                    answer: "In your mind, say “I wish you joy, abundance, health, and love”",
                    isCorrect: true
                )
            ]
        )
    ]
}
