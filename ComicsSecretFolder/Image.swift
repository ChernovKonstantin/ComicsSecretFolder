//
//  ImageFetcher.swift
//  ComicsSecretFolder
//
//  Created by Константин Чернов on 11.12.2020.
//

import Foundation

struct Image: Codable {
    private let path: String?
    private let ext: String?
    private let small = "/portrait_small"
    private let large = "/detail"
    
    private enum CodingKeys: String, CodingKey {
        case path
        case ext = "extension"
    }
}

extension Image {
    
    var url: URL? {
        if let path = path, let ext = ext {
            return URL(string: "\(path)\(small).\(ext)")
        } else {
            return nil
        }
    }
    var urlForBigTitle: URL? {
        if let path = path, let ext = ext {
            return URL(string: "\(path)\(large).\(ext)")
        } else {
            return nil
        }
    }
}


extension Image {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.path = try container.decodeIfPresent(String.self, forKey: .path)
        self.ext = try container.decodeIfPresent(String.self, forKey: .ext)
    }
}
