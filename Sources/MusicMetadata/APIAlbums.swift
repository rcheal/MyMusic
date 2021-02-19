//
//  APIAlbums.swift
//
//
//  Created by Robert Cheal on 1/15/21.
//

import Foundation

public struct APIAlbums {
    public var albums: [Album]
    public var _metadata: APIMetadata
    
    public init(albums: [Album], _metadata: APIMetadata) {
        self.albums = albums
        self._metadata = _metadata
    }
}

extension APIAlbums: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case albums
        case _metadata
    }
}
