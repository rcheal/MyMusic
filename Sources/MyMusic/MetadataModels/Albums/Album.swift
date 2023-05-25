//
//  Album.swift
//  
//
//  Created by Robert Cheal on 9/6/20.
//

import Foundation

/// A struct that stores metadata for an album along with path references to audio and artwork files
public struct Album: Identifiable, Equatable, Hashable {

    /// UUID which identifies the album within  the collection
    public var id: String
    /// Title of the album
    public var title: String
    /// Additional info that helps identify the album
    public var subtitle: String?
    /// Primary artist associated with the album
    public var artist: String?
    /// Newline separated list of supporting artists.  Add artists in the form - <name>:  <instrument>,...
    public var supportingArtists: String?
    /// Composer or 'Various'
    public var composer: String?
    /// Conductor or 'Various'
    public var conductor: String?
    /// Orchestra or 'Various'
    public var orchestra: String?
    /// Lyricist or 'Various'
    public var lyricist: String?
    /// Genre of music
    public var genre: String?
    public var publisher: String?
    public var copyright: String?
    public var encodedBy: String?
    public var encoderSettings: String?
    /// Year of recording
    public var recordingYear: Int?
    /// Summation of contents durations
    private var _duration: Int?
    public var duration: Int {
        get { _duration ?? 0 }
        set { _duration = newValue }
    }
    /// Relative directory that holds albums audio and artwork files
    public var directory: String?

    // Sort fields
    public var sortTitle: String?
    public var sortArtist: String?
    public var sortComposer: String?

    /// Collection or artwork related to album
    internal var _albumArt: AlbumArtwork?
    internal var albumArt: AlbumArtwork {
        get { _albumArt ?? AlbumArtwork() }
        set { _albumArt = newValue }
    }

    /// List of compositions and/or singles contained in album
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
