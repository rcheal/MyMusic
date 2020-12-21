//
//  SingleListItem.swift
//  
//
//  Created by Robert Cheal on 12/5/20.
//

import Foundation

public struct SingleListItem: Identifiable, Hashable {
    public var id: String
    public var compositionId: String?
    public var albumId: String?
    public var title: String
    public var artist: String?
    public var composer: String?
    public var genre: String?
    
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
        compositionId = single.compositionId
        albumId = single.albumId
        title = single.title
        sortTitle = Album.sortedTitle(single.title).lowercased()
        artist = single.artist
        sortArtist = Album.sortedPerson(single.artist)?.lowercased()
        composer = single.composer
        sortComposer = Album.sortedPerson(single.composer)?.lowercased()
        genre = single.genre
    }
    
}

extension SingleListItem: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case compositionId
        case albumId
        case title
        case artist
        case composer
        case genre
    }
}
