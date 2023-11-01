import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate{
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    
    private let presenter = MovieQuizPresenter()

    
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertProtocol?
    private var statisticService: StatisticService?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        
        imageView.layer.cornerRadius = 20
        showActivityIndicator()
        
        alertPresenter = AlertPresenter(viewController: self)
        statisticService = StatisticServiceImplementation()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didRecieveNextQuestion(question: QuizQuestion?) {
        presenter.didRecieveNextQuestion(question: question)
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkAlert(message: error.localizedDescription)
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        presenter.noButtonClicked()
    }
    
    // MARK: - Private functions
    
    func show(quiz step: QuizStepViewModel){
        imageView.image = step.image
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = 20
        
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else {return}
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    func show(quiz result: QuizResultsViewModel) {
            guard let statisticService = statisticService else {return}
        statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
            let bestGame = statisticService.bestGame
            
            let alert = AlertModel(
                title: result.title,
                message: """
                Ваш результат: \(presenter.correctAnswers)/\(presenter.questionsAmount)
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccurancy))%
                """,
                buttonText: result.buttonText) { [weak self] in
                    guard let self = self else {return}
                    
                    presenter.resetGame()
                    self.questionFactory?.requestNextQuestion()
                }
            
            alertPresenter?.show(alertModel: alert)
    }
    
    private func showActivityIndicator(){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    
    private func showNetworkAlert(message: String) {
        hideLoadingIndicator()
        
        let alert = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self = self else {return}
                
                presenter.resetGame()
                self.questionFactory?.requestNextQuestion()
            }
        
        alertPresenter?.show(alertModel: alert)
    }
    
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
}
