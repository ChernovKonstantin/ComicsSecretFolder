//
//  DataContainer.swift
//  ComicsSecretFolder
//
//  Created by Константин Чернов on 11.12.2020.
//

import Foundation

struct CharacterDataContainer: Codable {
    //    let offset: Int?
    //    let limit: Int?
    //    let count: Int?
    let total: Int?
    let results: [Character]?
}
