//
//  CompositionListItem.swift
//  
//
//  Created by Robert Cheal on 12/5/20.
//

import Foundation

public struct CompositionListItem: Identifiable, Hashable {
    public var id: String
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
        self.sortTitle = Album.sortedTitle(title).lowercased()
    }
    
    public init(_ composition: Composition) {
        id = composition.id
        albumId = composition.albumId
        title = composition.title
        sortTitle = Album.sortedTitle(composition.title).lowercased()
        artist = composition.artist
        sortArtist = Album.sortedPerson(composition.artist)?.lowercased()
        composer = composition.composer
        sortComposer = Album.sortedPerson(composition.sortComposer)?.lowercased()
        genre = composition.genre
    }
}
