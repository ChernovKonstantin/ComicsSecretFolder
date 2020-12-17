//
//  URLSessionModel.swift
//  ComicsSecretFolder
//
//  Created by Константин Чернов on 17.12.2020.
//

import Foundation

class URLSessionModel {
    
    static func urlRequest <T: Decodable> (from url: URL, completion: @escaping (Result<T, DataError>) -> Void) {
        URLSession.shared.dataTask(with: url){data, response, error in
            guard error == nil else { completion(.failure(.networkError)); return}
            guard let data = data else { completion(.failure(.invalidData)); return }
            do{
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch{
                completion(.failure(.decoding))
            }
        }.resume()
    }
    
    static func imageRequest (from url: URL, completion: @escaping (Result<Data, DataError>) -> Void) {
        URLSession.shared.dataTask(with: url){data, response, error in
            guard error == nil else { completion(.failure(.networkError)); return}
            guard let data = data else { completion(.failure(.invalidData)); return }
            completion(.success(data))
        }.resume()
    }
}
