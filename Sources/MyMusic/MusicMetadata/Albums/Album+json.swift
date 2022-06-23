//
//  Album+json.swift
//  
//
//  Created by Robert Cheal on 10/31/20.
//

import Foundation

extension Album {
    /// Returns JSON encoding of Album
    public var json: Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }

    /// Returns 'prettyPrinted' JSON encoding of Album
    ///
    /// Same as .json, except formats JSON for human readability
    public var jsonp: Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try? encoder.encode(self)
    }

    /// Creates Album from JSON encoding
    public static func decodeFrom(json: Data) -> Album? {
        let decoder = JSONDecoder()
        if let jsonAlbum = try? decoder.decode(Album.self, from: json) {
            return jsonAlbum
        }
        return nil
    }
}
