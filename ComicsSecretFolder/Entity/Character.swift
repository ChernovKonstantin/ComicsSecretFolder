//
//  Hero.swift
//  ComicsSecretFolder
//
//  Created by Константин Чернов on 11.12.2020.
//

import Foundation

struct Character: Codable {
    let id: Int?
    let name: String?
    let thumbnail: Image?
    var icon: Data?
}
