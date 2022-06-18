//
//  AlbumSummary.swift
//  
//
//  Created by Robert Cheal on 12/5/20.
//

import Foundation

/// Abbreviated form of Album to improve performance in album lists
public struct AlbumSummary: Identifiable, Hashable {
    
    public var id: String
    public var title: String
    public var artist: String?
    public var composer: String?
    public var genre: String?
    public var recordingYear: Int?
    public var frontArtFilename: String?
    public var directory: String?
    
    // Sort fields
    public var sortTitle: String?
    public var sortArtist: String?
    public var sortComposer: String?

    public init(_ id: String, title: String) {
        self.id = id
        self.title = title
        self.sortTitle = Album.sortedTitle(title).lowercased()
    }
    
    public init(_ album: Album) {
        id = album.id
        title = album.title
        sortTitle = album.sortTitle?.lowercased() ?? Album.sortedTitle(album.title).lowercased()
        artist = album.artist
        sortArtist = album.sortArtist?.lowercased() ?? Album.sortedPerson(album.artist)?.lowercased()
        composer = album.composer
        sortComposer = album.sortComposer?.lowercased() ?? Album.sortedPerson(album.composer)?.lowercased()
        genre = album.genre
        recordingYear = album.recordingYear
        frontArtFilename = album.frontArtRef()?.filename
        directory = album.directory
    }
        
}

extension AlbumSummary: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case title
        case artist
        case composer
        case genre
        case recordingYear
        case frontArtFilename
        case directory
        case sortTitle
        case sortArtist
        case sortComposer
    }
}
