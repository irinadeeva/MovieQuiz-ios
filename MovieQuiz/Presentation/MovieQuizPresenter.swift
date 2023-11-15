//
//  File.swift
//  MovieQuiz
//
//  Created by Irina Deeva on 31/10/23.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private var currentQuestionIndex = 0
    private let questionsAmount: Int = 10
    private var correctAnswers = 0

    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService?
    private weak var viewController: MovieQuizViewControllerProtocol?

    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController

        statisticService = StatisticServiceImplementation()

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }

    // MARK: - QuestionFactoryDelegate

    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }

    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }

    // MARK: - Internal functions

    func yesButtonClicked() {
        didAnswer(isYes: true)
    }

    func noButtonClicked() {
        didAnswer(isYes: false)
    }

    func resetGame() {
        correctAnswers = 0
        currentQuestionIndex = 0
        questionFactory?.requestNextQuestion()
    }

    func makeResultMessage() -> String {
        guard let statisticService = statisticService else {return ""}
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        let bestGame = statisticService.bestGame

        let message =  """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccurancy))%
        """

        return message
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }

    // MARK: - Private functions
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }

        self.proceedWithAnswer(isCorrect: isYes == currentQuestion.correctAnswer)
    }

    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }

    private func proceedWithAnswer(isCorrect: Bool) {
        self.didAnswer(isCorrectAnswer: isCorrect)

        viewController?.highlightImageBorder(isCorrect: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else {return}
            self.proceedNextQuestionOrResults()
        }
    }

    private func proceedNextQuestionOrResults() {
        if self.isLastQuestion() {
            let text = "Вы ответили на \(correctAnswers) из 10, попробуйте еще раз!"

            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }

    private func isLastQuestion() -> Bool {
        return currentQuestionIndex == questionsAmount - 1
    }
}
