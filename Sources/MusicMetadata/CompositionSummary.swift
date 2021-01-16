//
//  CompositionSummary.swift
//  
//
//  Created by Robert Cheal on 12/5/20.
//

import Foundation

public struct CompositionSummary: Identifiable, Hashable {
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
        recordingYear = composition.recordingYear
    }
}

extension CompositionSummary: Codable {
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
