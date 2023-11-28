//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Irina Deeva on 23/10/23.
//

import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: BestGame { get }

    func store(correct count: Int, total amount: Int)
}
