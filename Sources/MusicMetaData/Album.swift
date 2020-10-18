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

public struct Album: Codable, Identifiable, Hashable {
    public var id: String
    public var title: String
    public var sortTitle: String?
    public var subtitle: String?
    public var artist: String?
    public var sortArtist: String?
    public var supportingArtists: String?
    public var composer: String?
    public var sortComposer: String?
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
    
    public mutating func removeAllContents() {
        contents.removeAll()
    }
    
    public mutating func removeAllContents(where shouldBeRemoved: (AlbumContent) throws -> Bool) rethrows {
        try contents.removeAll(where: shouldBeRemoved)
    }
    
    public mutating func sortContents() {
        contents = contents.sorted { $0.track < $1.track }
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
    
    static func sortedTitle(_ title: String) -> String {
        var value = title
        if title.lowercased().hasPrefix("the ") {
            value = String(value.dropFirst(4))
        } else if title.lowercased().hasPrefix("a ") {
            value = String(value.dropFirst(2))
        } else if title.lowercased().hasPrefix("an ") {
            value = String(value.dropFirst(3))
        }
        return value
    }
    
    static func sortedPerson(_ person: String?) -> String? {
        if var value = person {
            // Remove 'A', 'An' or 'The'
            value = Album.sortedTitle(value)
            // Remove (birthyear-deathyear) from end of value
            let pattern = " *(\\d{4}-\\d{4}) *"
            if let dateRange = value.range(of: pattern, options:.regularExpression) {
                value.removeSubrange(dateRange)
            }
            value = value.trimmingCharacters(in: .whitespaces)
            // if person does not contain comma, strip last word and insert at front followed by ', ' and the rest of the field
            if !value.contains(",") {
                if let index = value.lastIndex(of: " ") {
                    let startIndex = value.startIndex
                    let endIndex = value.endIndex
                    let first = String(value[startIndex..<index])
                    let last = String(value[index..<endIndex].dropFirst())
                    value = last + ", " + first
                }
            }
            return value
        }
        return nil
    }
    
    public mutating func update() {
        sortTitle = Album.sortedTitle(title).lowercased()
        sortArtist = Album.sortedPerson(artist)?.lowercased()
        sortComposer = Album.sortedPerson(composer)?.lowercased()
        
        for index in contents.indices {
            if var composition = contents[index].composition {
                composition.update(self)
                contents[index].composition = composition
                
            } else if var single = contents[index].single {
                single.update(self)
                contents[index].single = single
            }
        }
        
        updateTracks()
        updateDuration()

    }
    
    mutating func updateTracks() {
        for index in contents.indices {
            if var composition = contents[index].composition {
                composition.updateTrack()
                contents[index].disk = composition.startDisk
                contents[index].track = composition.startTrack
            } else if let single = contents[index].single {
                contents[index].disk = single.disk
                contents[index].track = single.track
            }
        }
    }
    
    mutating func updateDuration() {
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
