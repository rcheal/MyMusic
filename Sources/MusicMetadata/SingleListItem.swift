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
    public var sortTitle: String?
    public var artist: String?
    public var sortArtist: String?
    public var composer: String?
    public var sortComposer: String?
    public var genre: String?

    public init(_ id: String, title: String) {
        self.id = id
        self.title = title
    }
    
    public init(_ single: Single) {
        id = single.id
        compositionId = single.compositionId
        albumId = single.albumId
        title = single.title
        sortTitle = Album.sortedTitle(single.title)
        artist = single.artist
        sortArtist = Album.sortedPerson(single.artist)
        composer = single.composer
        sortComposer = Album.sortedPerson(single.composer)
        genre = single.genre
    }
    
}

