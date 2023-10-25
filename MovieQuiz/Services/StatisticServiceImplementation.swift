//
//  StatisticServiceImplementation.swift
//  MovieQuiz
//
//  Created by Irina Deeva on 23/10/23.
//

import Foundation

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    var totalAccurancy: Double {
        get {
            return userDefaults.double(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        if Int(totalAccurancy) != 0 {
            totalAccurancy = (totalAccurancy + Double(count)/Double(amount) * 100.0)/2
        } else {
            totalAccurancy = Double(count)/Double(amount) * 100.0
        }
            
        gamesCount = gamesCount + 1
        
        if !bestGame.isHigher(than: count) {
            bestGame = GameRecord(correct: count, total: amount, date: Date())
        }
    }
    
}


private enum Keys: String {
    case correct, total, bestGame, gamesCount
}
