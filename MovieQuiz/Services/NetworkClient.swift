//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Irina Deeva on 27/10/23.
//

import Foundation

protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping(Result<Data, Error>) -> Void)
}

struct NetworkClient: NetworkRouting {
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetch(url: URL, handler: @escaping(Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error {
                handler(.failure(error))
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
            }
            
            guard let data else {return}
            handler(.success(data))
        }
        
        task.resume()
    }
}
