//
//  Playlist+json.swift
//  
//
//  Created by Robert Cheal on 1/16/21.
//

import Foundation

extension Playlist {
    /// Returns JSON encoding of Playlist
    public var json: Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }

    /// Returns 'prettyPrinted' JSON encoding of Playlist
    ///
    /// Same as .json except format JSON for human readability
    public var jsonp: Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try? encoder.encode(self)
    }

    /// Creates Playlist from JSON encoding
    public static func decodeFrom(json: Data) -> Playlist? {
        let decoder = JSONDecoder()
        if let jsonPlaylist = try? decoder.decode(Playlist.self, from: json) {
            return jsonPlaylist
        }
        return nil
    }
}
