//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Irina Deeva on 02/10/23.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    @MainActor func didRecieveNextQuestion(question: QuizQuestion)
	@MainActor func didLoadDataFromServer()
	@MainActor func didFailToLoadData(with error: Error)
}
