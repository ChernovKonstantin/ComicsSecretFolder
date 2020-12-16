//
//  CreatorDataContainer.swift
//  ComicsSecretFolder
//
//  Created by Константин Чернов on 12.12.2020.
//

import Foundation

struct CreatorDataContainer: Codable {
    //    let offset: Int?
    //    let limit: Int?
    //    let count: Int?
    let total: Int?
    let results: [Creator]?
}
