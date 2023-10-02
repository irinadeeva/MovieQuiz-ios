//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Irina Deeva on 02/10/23.
//
import UIKit

class AlertPresenter {
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
}

extension AlertPresenter: AlertProtocol {
    func show(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
           alertModel.completion()
        }
        
        alert.addAction(action)
        viewController?.present(alert, animated: true)
    }
}
