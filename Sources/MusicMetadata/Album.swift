//
//  Album.swift
//  
//
//  Created by Robert Cheal on 9/6/20.
//

import Foundation

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
    
    public internal(set) var contents: [AlbumContent] = []
    
    public init(title: String) {
        id = UUID().uuidString
        duration = 0
        self.title = title
    }
        
}

public enum MetadataImageType {
    case frontCover
    case backCover
}

