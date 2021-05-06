//
//  Album.swift
//  
//
//  Created by Robert Cheal on 9/6/20.
//

import Foundation

public struct Album: Identifiable, Hashable {
    
    public var id: String
    public var title: String
    public var subtitle: String?
    public var artist: String?
    public var supportingArtists: String?
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
    private var _duration: Int?       /// sumation of contents durations
    public var duration: Int {
        get { _duration ?? 0 }
        set { _duration = newValue }
    }
    public var directory: String?

    // Sort fields
    public var sortTitle: String?
    public var sortArtist: String?
    public var sortComposer: String?
    
    internal var _albumArt: AlbumArtwork?
    internal var albumArt: AlbumArtwork {
        get { _albumArt ?? AlbumArtwork() }
        set { _albumArt = newValue }
    }

    public internal(set) var contents: [AlbumContent] = []
    
    public init(title: String) {
        id = UUID().uuidString
        self.title = title
    }
    
    public init(summary: AlbumSummary) {
        id = summary.id
        title = summary.title
        artist = summary.artist
        composer = summary.composer
        genre = summary.genre
        recordingYear = summary.recordingYear
        directory = summary.directory
        addArt(AlbumArtRef(type: .front, format: summary.frontArtFilename == "front.png" ? .png : .jpg))
    }
        
}

extension Album: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case id
        case title
        case subtitle
        case artist
        case supportingArtists
        case composer
        case conductor
        case orchestra
        case lyricist
        case genre
        case publisher
        case copyright
        case encodedBy
        case encoderSettings
        case recordingYear
        case _duration = "duration"
        case directory
        case _albumArt = "albumArt"
        case contents
        case sortTitle
        case sortArtist
        case sortComposer
    }
}
