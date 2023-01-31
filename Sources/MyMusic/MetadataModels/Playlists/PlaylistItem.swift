//
//  PlaylistItem.swift
//  
//
//  Created by Robert Cheal on 5/23/22.
//

import Foundation

/// Type of playlist item - album, composition, movement or single
public enum PlaylistItemType: String, Codable {
    case album
    case composition
    case movement
    case single
}

/// Struct containing single item in playlist
///
/// A playlist item may be an album, a composition, a movement or a single.
/// PlaylistItemType is implied by the constructor used.
public struct PlaylistItem: Identifiable, Hashable {

    public var id: String
    public var albumId: String?
    public var compositionId: String?
    public var title: String
    public var artist: String?
    public var composer: String?
    public var genre: String?
    public var albumTitle: String?
    public var playlistType: PlaylistItemType

    public var items: [PlaylistItem]?

    // Album
    public init(_ album: AlbumSummary, items: [PlaylistItem]? = nil) {
        self.id = album.id
        self.title = album.title
        self.artist = album.artist
        self.composer = album.composer
        self.genre = album.genre
        self.playlistType = .album
        self.items = items
    }

    // Composition
    public init(_ composition: CompositionSummary, items: [PlaylistItem]? = nil) {
        self.id = composition.id
        self.albumId = composition.albumId
        self.title = composition.title
        self.artist = composition.artist
        self.composer = composition.composer
        self.genre = composition.genre
        self.playlistType = .composition
        self.items = items
    }

    // Movement
    public init(_ movement: Movement) {
        self.id = movement.id
        self.albumId = movement.albumId
        self.compositionId = movement.compositionId
        self.title = movement.title
        self.playlistType = .movement
    }

    // Single
    public init(_ single: SingleSummary) {
        self.id = single.id
        self.albumId = single.albumId
        self.title = single.title
        self.artist = single.artist
        self.composer = single.composer
        self.genre = single.genre
        self.playlistType = .single
    }

}

extension PlaylistItem: Codable {

    public enum CodingKeys: String, CodingKey {
        case id
        case albumId
        case compositionId
        case title
        case artist
        case composer
        case genre
        case albumTitle
        case playlistType
        case items
    }
}
