//
//  Album.swift
//  
//
//  Created by Robert Cheal on 9/6/20.
//

import Foundation

public struct AlbumContent: Codable, Identifiable {
    public var id: String?  // Copy of composition.id or single.id
    public var disk: Int?
    public var track: Int
    public var composition: Composition?
    public var single: Single?
}

public struct Album: Codable, Identifiable {
    public var id: String?
    public var title: String
    public var subtitle: String?
    public var artist: String?
    public var supportingArtists: [String]?
    public var composer: String?
    public var conductor: String?
    public var orchestra: String?
    public var lyricist: String?
    public var genre: String?
    public var publisher: String?
    public var copyright: String?
    public var encodedBy: String?
    public var encoderSettings: String?
    public var recordingYear: Int?
    public var duration: Int?       /// sumation of contents durations

    public var frontCoverArtRef: String?
    public var backCoverArtRef: String?
    
    public var contents: [AlbumContent] = []
    
    init(title: String) {
        self.title = title
    }
    
    var json: Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
    
    public static func decodeFrom(json: Data) -> Album? {
        let decoder = JSONDecoder()
        if let jsonAlbum = try? decoder.decode(Album.self, from: json) {
            return jsonAlbum
        }
        return nil
    }
    
}
