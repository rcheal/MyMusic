//
//  AlbumListItem.swift
//  
//
//  Created by Robert Cheal on 12/5/20.
//

import Foundation

public struct AlbumListItem: Identifiable, Hashable {
    
    public var id: String
    public var title: String
    public var sortTitle: String?
    public var artist: String?
    public var sortArtist: String?
    public var composer: String?
    public var sortComposer: String?
    public var genre: String?
    public var recordingYear: Int?
    public var frontArtFilename: String?
    public var directory: String?
    
    public init(_ id: String, title: String) {
        self.id = id
        self.title = title
        self.sortTitle = Album.sortedTitle(title).lowercased()
    }
    
    public init(_ album: Album) {
        id = album.id
        title = album.title
        sortTitle = Album.sortedTitle(album.title).lowercased()
        artist = album.artist
        sortArtist = Album.sortedPerson(album.artist)?.lowercased()
        composer = album.composer
        sortComposer = Album.sortedPerson(album.composer)?.lowercased()
        genre = album.genre
        recordingYear = album.recordingYear
        frontArtFilename = album.frontArtRef()?.filename
        directory = album.directory
    }
        
}

extension AlbumListItem: Codable {
    
}
