//
//  CharacterFetching.swift
//  ComicsSecretFolder
//
//  Created by Константин Чернов on 11.12.2020.
//

import Foundation

class FetchingData {
    
    
    var searchingOption: SearchingPropetries?
    private var requestMaker = URLSessionModel()
    
    private let basicUrl = "https://gateway.marvel.com:443/v1/public/"
    private var timestamp = NSDate().timeIntervalSince1970
    private let publicKey = "928054e701cedf1af1479e0c91a10e3a"
    private let privateKey = "671a48ae623069610ee89320f6833ff74b9646ce"
    private lazy var hash = "\(timestamp)\(privateKey)\(publicKey)"
    
    private var requestLimit = 30
    private var requestOffset = 0
    private var totalRecordsCount = 0
    var searchingParameterValue = ""
    var searchingParameterValueForComics = ""
    private(set) var acceptableChars = "1234567890abcdefghijklmnopqrstuvwxyz- "
    private var imagesRequestedForCells = [Int]()
    
    init() {
    }
    
    init(searching type: SearchingPropetries) {
        self.searchingOption = type
    }
    
    private var urlForRequest: URL{
        switch searchingOption {
        case .forCharacters:
            return URL(string: "\(basicUrl)characters?nameStartsWith=\(searchingParameterValue)&limit=\(requestLimit)&offset=\(requestOffset)&ts=\(timestamp)&apikey=\(publicKey)&hash=\(requestMaker.toMD5(from: hash))")!
        case .forCreators:
            return URL(string: "\(basicUrl)creators?nameStartsWith=\(searchingParameterValue)&limit=\(requestLimit)&offset=\(requestOffset)&ts=\(timestamp)&apikey=\(publicKey)&hash=\(requestMaker.toMD5(from: hash))")!
        case .comicsByCharacterID:
            return URL(string: "\(basicUrl)comics?characters=\(searchingParameterValue)&limit=\(requestLimit)&offset=\(requestOffset)&ts=\(timestamp)&apikey=\(publicKey)&hash=\(requestMaker.toMD5(from: hash))")!
        case .comicsByCreator:
            return URL(string: "\(basicUrl)comics?creators=\(searchingParameterValue)&limit=\(requestLimit)&offset=\(requestOffset)&ts=\(timestamp)&apikey=\(publicKey)&hash=\(requestMaker.toMD5(from: hash))")!
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
        totalRecordsCount > (requestOffset - 1)
    }
    
    func updateOffsetForRequest(){
        requestOffset += requestLimit
    }
    
    func newSearch(){
        imagesRequestedForCells.removeAll()
        requestOffset = 0
        totalRecordsCount = 0
    }
    
    func downloadData <R: Codable> (completion: @escaping (Result<[R], Error>) -> Void) {
        requestMaker.urlRequest(from: self.urlForRequest)
        { (result: Result<MarvelData<R>, DataError>) in
            switch result{
            case .failure(let error): completion(.failure(error))
            case .success(let container):
                if let data = container.data?.results{
                    self.totalRecordsCount = container.data?.total ?? 0
                    completion(.success(data))
                    self.updateOffsetForRequest()
                }
            }
        }
    }
    func fetchImage(forCell index: Int, url: URL, completion: @escaping (Data) -> Void){
        guard !imagesRequestedForCells.contains(index) else {return}
        imagesRequestedForCells.append(index)
        requestMaker.imageRequest(from: url){ image in
            completion(image)
        }
        
    }
}
