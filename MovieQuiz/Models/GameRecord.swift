//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Irina Deeva on 23/10/23.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int // bestResult?
    let total: Int
    let date: Date
    
    func isHigher(than another: Int) -> Bool { // isNewBestRecord(_ currentResult: Int) -> Bool  maybe?
        return correct > another
    }
}
