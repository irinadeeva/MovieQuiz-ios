//
//  File.swift
//  MovieQuiz
//
//  Created by Irina Deeva on 31/10/23.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate{
    private var currentQuestionIndex = 0 // from currentQuestionIndex questionsAmount, correctAnswers would make GameStateDataStore
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
    
    func didRecieveNextQuestion(question: QuizQuestion) {
        currentQuestion = question
		guard let viewModel = convert(model: question) else { return }
		self.viewController?.show(quiz: viewModel)
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
    
    func convert(model: QuizQuestion) -> QuizStepViewModel? {
		guard let image = UIImage(data: model.image) else {
			assertionFailure("Did expect image")
			return nil
		}
        return QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
		)
    }
    
    // MARK: - Private functions
    
    private func didAnswer(isYes: Bool){
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
            guard let self else {return}
            self.proceedNextQuestionOrResults()
			self.viewController?.hideImageBorder()
        }
    }
    
    private func proceedNextQuestionOrResults() {
        if self.isLastQuestion() {
            let text = "Вы ответили на \(correctAnswers) из 10, попробуйте еще раз!" // вынести все строки в struct Constants с static properties. E.g static let resultText = "Вы ответили на %@ из 10, попробуйте еще раз!" и тд.
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
			)
            viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func isLastQuestion() -> Bool {
        return currentQuestionIndex == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
}
