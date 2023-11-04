//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Irina Deeva on 27/10/23.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> ())
}

struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient: NetworkRouting

    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }

    // MARK: - URL
    private let mostPopularMoviesUrl: URL? = {
        guard let url = URL(string: "https://imdb-api.com/API/Top250Movies/k_zcuw1ytf") else {
            assertionFailure("Unable to construct mostPopilarMoviesURL") // this will crash the app (even on prod) if string is empty or has spaces. Better to handle with popUp. To crash only on dev use assertionFailure
			return nil
        }
        return url
    }()

	func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> ()) {
		guard let mostPopularMoviesUrl else { return }
		
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
