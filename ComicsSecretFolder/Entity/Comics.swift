//
//  Comics.swift
//  ComicsSecretFolder
//
//  Created by Константин Чернов on 12.12.2020.
//

import Foundation

struct Comics: Codable{
    let id: Int?
    let title: String?
    let thumbnail: Image?
    var icon: Data?
    let prices: [ComicPrice]?
    let images: [Image]?
}


