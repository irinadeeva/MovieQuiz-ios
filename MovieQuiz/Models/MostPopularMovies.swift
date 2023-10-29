//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Irina Deeva on 27/10/23.
//

import Foundation

struct MostPopularMovies: Codable {
    let error: String
    let items: [MostPopularMovie]
}

struct MostPopularMovie: Codable {
    let title: String
    let rating: String
    let imageURL: URL
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
}
