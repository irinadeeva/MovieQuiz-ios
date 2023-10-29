//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Irina Deeva on 27/10/23.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(hanlder: @escaping (Result<MostPopularMovies, Error>) -> Void)
}


struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient = NetworkClient()
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://imdb-api.com/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopilarMoviesURL")
        }
        return url
    }
    
    func loadMovies(hanlder: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    hanlder(.success(mostPopularMovies))
                } catch {
                    hanlder(.failure(error))
                }
            case .failure(let error):
                hanlder(.failure(error))
            }
        }
    }
}
