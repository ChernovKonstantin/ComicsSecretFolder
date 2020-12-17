//
//  DataError.swift
//  ComicsSecretFolder
//
//  Created by Константин Чернов on 17.12.2020.
//

import Foundation

enum DataError: Error {
    case networkError
    case invalidData
    case decoding
}
