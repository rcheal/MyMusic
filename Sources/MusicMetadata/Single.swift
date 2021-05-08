//
//  Single.swift
//  
//
//  Created by Robert Cheal on 9/6/20.
//

import Foundation

public struct Single: Identifiable, Hashable {
    public var id: String
    public var compositionId: String?
    public var albumId: String?
    public var disk: Int?
    public var track: Int {
        get { _track ?? 0 }
        set { _track = newValue}
    }
    private var _track: Int?
    
    
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
    public var duration: Int {       /// duration in seconds
        get { _duration ?? 0 }
        set { _duration = newValue}
    }
    private var _duration: Int?
    public var directory: String?   /// for orphaned singles only

    // Sort fields
    public var sortTitle: String?
    public var sortArtist: String?
    public var sortComposer: String?

    public var filename: String {
        get { _filename ?? "" }
        set { _filename = newValue }
    }
    private var _filename: String?

    public init(title: String, filename: String, track: Int? = nil, disk: Int? = nil) {
        id = UUID().uuidString
        self.disk = disk
        self._track = track
        self.title = title
        self.filename = filename
    }
    
    public init(summary: SingleSummary) {
        id = summary.id
        albumId = summary.albumId
        title = summary.title
        artist = summary.artist
        composer = summary.composer
        genre = summary.genre
        recordingYear = summary.recordingYear
        track = 0
    }
    
}

extension Single: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case compositionId
        case albumId
        case disk
        case _track = "track"
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
        case sortTitle
        case sortArtist
        case sortComposer
        case _filename = "filename"
    }
}
