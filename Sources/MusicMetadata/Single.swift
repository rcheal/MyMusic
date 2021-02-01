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
    public var track: Int
    
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
    public var duration: Int       /// duration in seconds
    public var directory: String?   /// for orphaned singles only

    // Sort fields
    public var sortTitle: String?
    public var sortArtist: String?
    public var sortComposer: String?

    public var filename: String

    public init(track: Int, title: String, filename: String, disk: Int? = nil) {
        id = UUID().uuidString
        duration = 0
        self.disk = disk
        self.track = track
        self.title = title
        self.filename = filename
    }
    
}

extension Single: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case compositionId
        case albumId
        case disk
        case track
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
        case duration
        case directory
        case sortTitle
        case sortArtist
        case sortComposer
        case filename
    }
}
