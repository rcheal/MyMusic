//
//  Album.swift
//  
//
//  Created by Robert Cheal on 9/6/20.
//

import Foundation

public struct AlbumContent: Codable, Identifiable, Hashable {
    public var id: String  // Copy of composition.id or single.id
    public var disk: Int?
    public var track: Int
    public var composition: Composition?
    public var single: Single?
    
    public init(track: Int, composition: Composition, disk: Int? = nil) {
        id = composition.id
        self.track = track
        self.composition = composition
        self.disk = disk
    }
    
    public init(track: Int, single: Single, disk: Int? = nil) {
        id = single.id
        self.track = track
        self.single = single
        self.disk = disk
    }
}

public struct Album: Codable, Identifiable {
    public var id: String
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
    public var duration: Int       /// sumation of contents durations

    public var frontCoverArtRef: String?
    public var backCoverArtRef: String?
    
    public private(set) var contents: [AlbumContent] = []
    
    public init(title: String) {
        id = UUID().uuidString
        duration = 0
        self.title = title
    }
    
    public mutating func addContent(_ content: AlbumContent) {
        contents.append(content)
        if let composition = content.composition {
            duration += composition.duration
        } else if let single = content.single {
            duration += single.duration
        }
    }
    
    public mutating func replaceComposition(_ composition: Composition) {
        let compIndex = contents.firstIndex(where:
            { (c) in
                c.id == composition.id
            }) ?? -1
        if compIndex >= 0 {
            var content = contents[compIndex]
            content.composition = composition
            contents[compIndex] = content
            updateDuration()
        }
    }
    
    public mutating func replaceSingle(_ single: Single) {
        let singleIndex = contents.firstIndex(where:
            { (s) in
                s.id == single.id
            }) ?? -1
        if singleIndex >= 0 {
            var content = contents[singleIndex]
            content.single = single
            contents[singleIndex] = content
            updateDuration()
        }
    }
    
    public mutating func replaceSingle(_ single: Single, composition: Composition) {
        let compIndex = contents.firstIndex(where:
            { (c) in
                c.id == composition.id
            }) ?? -1
        if compIndex >= 0 {
            var comp = composition
            comp.replaceSingle(single)
            var content = contents[compIndex]
            content.composition = comp
            contents[compIndex] = content
            updateDuration()
        }
    }
    
    public mutating func updateDuration() {
        duration = 0
        for content in contents {
            if let single = content.single {
                duration += single.duration
            } else if let composition = content.composition {
                duration += composition.duration
            }
        }
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
