//
//  Creator.swift
//  ComicsSecretFolder
//
//  Created by Константин Чернов on 11.12.2020.
//

import Foundation

struct Creator: Codable {
    let id: Int?
    let fullName: String?
    let thumbnail: Image?
    var icon: Data?
}
