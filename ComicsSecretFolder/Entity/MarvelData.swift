//
//  MarvelData.swift
//  ComicsSecretFolder
//
//  Created by Константин Чернов on 22.12.2020.
//

import Foundation

struct MarvelData<T: Codable>: Codable{
//    let code: Int?
//    let status: String?
    let data: DataContainer<T>?
//    let etag: String?
//    let copyright: String?
//    let attributionText: String?
//    let attributionHTML: String?
}
