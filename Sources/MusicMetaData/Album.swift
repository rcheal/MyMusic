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
    
    public init(track: Int, composition: Composition, disk: Int? = nil) {
        self.track = track
        self.composition = composition
        self.disk = disk
    }
    
    public init(track: Int, single: Single, disk: Int? = nil) {
        self.track = track
        self.single = single
        self.disk = disk
    }
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
    
    public init(title: String) {
        self.title = title
    }
    
    public var json: Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
    
    public var jsonp: Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
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
