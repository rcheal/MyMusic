//
//  Composition.swift
//  
//
//  Created by Robert Cheal on 9/6/20.
//

import Foundation

public struct Composition: Identifiable, Hashable {
    public var id: String
    public var albumId: String?
    public var startDisk: Int?
    public var startTrack: Int
    
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

    // Sort fields
    public var sortTitle: String?
    public var sortArtist: String?
    public var sortComposer: String?

    public internal(set) var movements: [Movement] = []
    
    public init(title: String, track: Int, disk: Int? = nil) {
        id = UUID().uuidString
        duration = 0
        self.startTrack = track
        self.title = title
        self.startDisk = disk
    }
    
    public init(summary: CompositionSummary) {
        id = summary.id
        albumId = summary.albumId
        title = summary.title
        artist = summary.artist
        composer = summary.composer
        genre = summary.genre
        recordingYear = summary.recordingYear
        duration = 0
        startTrack = 0
    }
    
}

extension Composition: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case albumId
        case startDisk
        case startTrack
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
        case movements
    }

}
