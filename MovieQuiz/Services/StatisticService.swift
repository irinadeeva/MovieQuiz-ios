//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Irina Deeva on 23/10/23.
//

import Foundation

protocol StatisticService{
    var totalAccurancy: Double {get}
    var gamesCount: Int {get}
    var bestGame: GameRecord {get}
    
    func store(correct count: Int, total amount: Int)
}
