//
//  DataContainer.swift
//  ComicsSecretFolder
//
//  Created by Константин Чернов on 22.12.2020.
//

import Foundation

struct DataContainer<T: Codable>: Codable  {
    //    let offset: Int?
    //    let limit: Int?
    //    let count: Int?
    let total: Int?
    let results: [T]?
}
