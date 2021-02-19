//
//  APIAlbums.swift
//
//
//  Created by Robert Cheal on 1/15/21.
//

import Foundation

public struct APIAlbums {
    var albums: [Album]
    var _metadata: APIMetadata
}

extension APIAlbums: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case albums
        case _metadata
    }
}
