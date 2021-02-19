//
//  APIPlaylists.swift
//  
//
//  Created by Robert Cheal on 1/16/21.
//

import Foundation

public struct APIPlaylists {
    public var playlists: [Playlist]
    public var _metadata: APIMetadata
    
    public init(playlists: [Playlist], _metadata: APIMetadata) {
        self.playlists = playlists
        self._metadata = _metadata
    }
}

extension APIPlaylists: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case playlists
        case _metadata
    }
}
