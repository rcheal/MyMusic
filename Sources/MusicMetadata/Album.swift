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

    internal var albumArt: AlbumArtwork = AlbumArtwork()

    public internal(set) var contents: [AlbumContent] = []
    
    public init(title: String) {
        id = UUID().uuidString
        duration = 0
        self.title = title
    }
        
}

extension Album: Codable {
    
    enum CodingKeys: String, CodingKey {
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
        case duration
        case albumArt
        case contents
    }
}

public enum MetadataImageType {
    case frontCover
    case backCover
}

