//
//  APIPlaylists.swift
//  
//
//  Created by Robert Cheal on 1/16/21.
//

import Foundation

/// Struct containing list of palylists
public struct APIPlaylists {
    /// List of playlists requested by client
    public var playlists: [Playlist]
    private var _metadata: APIMetadata
    
    public init(playlists: [Playlist], _metadata: APIMetadata) {
        self.playlists = playlists
        self._metadata = _metadata
    }

    /// Request metadata related to playlist list
    /// - Returns: ``APIMetadata``
    public func getMetadata() -> APIMetadata { _metadata }
}

extension APIPlaylists: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case playlists
        case _metadata
    }
}
