//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Irina Deeva on 26/09/23.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
	
    private weak var delegate: QuestionFactoryDelegate?

    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
			guard let self else { return }
			Task {
				switch result {
				case .success(let mostPopularMovies):
					//would load image immediately together
					self.movies = mostPopularMovies.items
					await self.delegate?.didLoadDataFromServer()
				case .failure(let error):
					await self.delegate?.didFailToLoadData(with: error)
				}
			}
        }
    }

    func requestNextQuestion() {
		// why random? why not last?
		guard let movie = self.movies.randomElement() else {
			assertionFailure("Expect some movie")// после "еще раз", краш. Need communication about the error to the user (popUp)
			return
		}

		DispatchQueue.global().async { [weak self] in
			guard let self else { return }
			guard let imageData = try? Data(contentsOf: movie.resizedImageURL ?? movie.imageURL) // in a sense, convertation of URL into Data is a Network operation. If there're no internet, Data wouldn't be loaded. Maybe NetworkClient is a better class to have the operation there.
			else {
				assertionFailure("Failed to load image") // would be nice to have communication about the error to the user (popUp)
				return
			}
			
			let rating = Float(movie.rating) ?? 0
			let ratingBenchmark = Int.random(in: 7..<9)
			let text = "Рейтинг этого фильма больше чем \(ratingBenchmark)?" // would fit better in presenter, better to make constant
			let correctAnswer = rating > Float(ratingBenchmark)

			let question = QuizQuestion(
				image: imageData,
				text: text,
				correctAnswer: correctAnswer
			)

			Task {
				await self.delegate?.didRecieveNextQuestion(question: question)
			}
		}
    }
}
