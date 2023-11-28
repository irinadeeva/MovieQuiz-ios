//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Irina Deeva on 23/10/23.
//

import Foundation

struct BestGame: Codable {
    let correct: Int
    let total: Int
    let date: Date

    func isHigher(than another: Int) -> Bool {
        return correct > another
    }
}
