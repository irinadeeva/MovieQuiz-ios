//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Irina Deeva on 02/10/23.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
