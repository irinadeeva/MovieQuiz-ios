import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
	func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    func highlightImageBorder(isCorrect: Bool)
	func hideImageBorder()
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self) //move to builder
        
        imageView.layer.cornerRadius = 20
		imageView.layer.masksToBounds = true
		
        alertPresenter = AlertPresenter(viewController: self)
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Internal functions
    
    func show(quiz step: QuizStepViewModel) { // I would name MovieQuizViewControllerViewModel
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultMessage()
        
        let alert = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText
		) { [weak self] in
			guard let self = self else { return }
			self.presenter.resetGame()
		}
        
        alertPresenter?.show(alertModel: alert)
    }
    
    func highlightImageBorder(isCorrect: Bool) {
//        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки 🤔 idk. Could be done just once, e.g in viewDidLoad
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

	func hideImageBorder() {
		imageView.layer.borderWidth = 0
	}

    func showLoadingIndicator(){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alert = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
		) { [weak self] in
			guard let self else { return }
			self.presenter.resetGame()
		}

        alertPresenter?.show(alertModel: alert)
    }
}
