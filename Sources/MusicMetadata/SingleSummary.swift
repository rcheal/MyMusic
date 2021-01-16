//
//  SingleSummary.swift
//  
//
//  Created by Robert Cheal on 12/5/20.
//

import Foundation

public struct SingleSummary: Identifiable, Hashable {
    public var id: String
    public var albumId: String?
    public var title: String
    public var artist: String?
    public var composer: String?
    public var genre: String?
    public var recordingYear: Int?
    
    // Sort fields
    public var sortTitle: String?
    public var sortArtist: String?
    public var sortComposer: String?

    public init(_ id: String, title: String) {
        self.id = id
        self.title = title
        self.sortTitle = Album.sortedTitle(title).lowercased()
    }
    
    public init(_ single: Single) {
        id = single.id
        albumId = single.albumId
        title = single.title
        sortTitle = Album.sortedTitle(single.title).lowercased()
        artist = single.artist
        sortArtist = Album.sortedPerson(single.artist)?.lowercased()
        composer = single.composer
        sortComposer = Album.sortedPerson(single.composer)?.lowercased()
        genre = single.genre
        recordingYear = single.recordingYear
    }
    
}

extension SingleSummary: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case albumId
        case title
        case artist
        case composer
        case genre
        case recordingYear
        case sortTitle
        case sortArtist
        case sortComposer
    }
}
