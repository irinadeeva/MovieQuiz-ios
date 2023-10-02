//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Irina Deeva on 02/10/23.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
