//
//  CharacterFetching.swift
//  ComicsSecretFolder
//
//  Created by Константин Чернов on 11.12.2020.
//

import Foundation
import CryptoKit

class FetchingData {
    
    var searchingOption: SearchingPropetries?
    
    private let basicUrl = "https://gateway.marvel.com:443/v1/public/"
    private var timestamp = NSDate().timeIntervalSince1970
    
    private let publicKey = "928054e701cedf1af1479e0c91a10e3a"
    private let privateKey = "671a48ae623069610ee89320f6833ff74b9646ce"
    private lazy var hash = "\(timestamp)\(privateKey)\(publicKey)".MD5
    
    private(set) var currentURLRequestIndex = 0
    private var requestLimit = 30
    private(set) var requestOffset = 0
    var totalRecordsCount = 0
    var searchingParameterValue = ""
    var searchingParameterValueForComics = ""
    var additionalRequestInProcess = false
    private(set) var acceptableChars = "abcdefghijklmnopqrstuvwxyz- "
    
    init() {
    }
    
    init(searching type: SearchingPropetries) {
        self.searchingOption = type
    }
    
    private var urlForRequest: URL{
        switch searchingOption {
        case .forCharacters:
            return URL(string: "\(basicUrl)characters?nameStartsWith=\(searchingParameterValue)&limit=\(requestLimit)&offset=\(requestOffset)&ts=\(timestamp)&apikey=\(publicKey)&hash=\(hash)")!
        case .forCreators:
            return URL(string: "\(basicUrl)creators?nameStartsWith=\(searchingParameterValue)&limit=\(requestLimit)&offset=\(requestOffset)&ts=\(timestamp)&apikey=\(publicKey)&hash=\(hash)")!
        case .comicsByCharacterID:
            return URL(string: "\(basicUrl)comics?characters=\(searchingParameterValue)&limit=\(requestLimit)&offset=\(requestOffset)&ts=\(timestamp)&apikey=\(publicKey)&hash=\(hash)")!
        case .comicsByCreator:
            return URL(string: "\(basicUrl)comics?creators=\(searchingParameterValue)&limit=\(requestLimit)&offset=\(requestOffset)&ts=\(timestamp)&apikey=\(publicKey)&hash=\(hash)")!
        case .none: return URL(string: basicUrl)!
        }
    }
    
    enum SearchingPropetries{
        case forCharacters
        case forCreators
        case comicsByCharacterID
        case comicsByCreator
    }
    
    var additionalDataIsAvailable: Bool
    {
        totalRecordsCount > (requestOffset + (requestLimit-1))
    }
    
    func updateOffsetForRequest(){
        requestOffset += requestLimit
    }
    
    func newSearch(){
        currentURLRequestIndex += 1
        requestOffset = 0
        totalRecordsCount = 0
    }
    
    func downloadData <R: Codable> (forRequest currentURLRequest: Int, completion: @escaping (Result<[R], Error>) -> Void) {
        URLSessionModel.urlRequest(from: self.urlForRequest)
        { (result: Result<MarvelData<R>, DataError>) in
            guard currentURLRequest == self.currentURLRequestIndex else { return }
            switch result{
            case .failure(let error): completion(.failure(error))
            case .success(let container):
                if let data = container.data?.results{
                    self.additionalRequestInProcess = false
                    self.totalRecordsCount = container.data?.total ?? 0
                    completion(.success(data))
                }
            }
        }
    }
    
    func fetchImage(forCell index: Int, forRequest: Int, url: URL, completion: @escaping (Data) -> Void){
        if let data = try? Data(contentsOf: url){
            guard forRequest == self.currentURLRequestIndex else { return }
            completion(data)
        }
    }
}

//MARK: - md5 encoding extension

extension String {
    fileprivate var MD5: String {
        let computed = Insecure.MD5.hash(data: self.data(using: .utf8)!)
        return computed.map { String(format: "%02hhx", $0) }.joined()
    }
}
