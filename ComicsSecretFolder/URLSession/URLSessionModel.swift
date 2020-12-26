//
//  URLSessionModel.swift
//  ComicsSecretFolder
//
//  Created by Константин Чернов on 17.12.2020.
//

import Foundation
import CryptoKit

class URLSessionModel {
    
    private var dataTask: URLSessionDataTask?
    private var imageTask: URLSessionDataTask?
    
    func urlRequest <T: Decodable> (from url: URL, completion: @escaping (Result<T, DataError>) -> Void) {
        guard dataTask == nil else {return}
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.dataTask = URLSession.shared.dataTask(with: url){data, response, error in
                
                guard error == nil else { completion(.failure(.networkError)); return}
                guard let data = data else { completion(.failure(.invalidData)); return }
                do{
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedData))
                } catch{
                    completion(.failure(.decoding))
                }
                self?.dataTask = nil
            }
            self?.dataTask?.resume()
        }
    }
    func imageRequest (from url: URL, completion: @escaping (Data) -> Void) {
        guard imageTask == nil else {return}
        DispatchQueue.global(qos: .userInitiated).async {
            URLSession.shared.dataTask(with: url){data, _, _ in
                guard let data = data else { return }
                completion(data)
                self.imageTask = nil
            }.resume()
        }
    }
    
    func toMD5(from input:String) -> String {
        let computed = Insecure.MD5.hash(data: input.data(using: .utf8)!)
        return computed.map { String(format: "%02hhx", $0) }.joined()
    }
}
