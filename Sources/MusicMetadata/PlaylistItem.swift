//
//  PlaylistItem.swift
//  
//
//  Created by Robert Cheal on 5/23/22.
//

import Foundation

public enum PlaylistItemType: String, Codable {
    case playqueue
    case playlist
    case album
    case composition
    case movement
    case single
}

public struct PlaylistItem: Identifiable, Hashable {

    public var playlistType: PlaylistItemType
    public var id: String
    public var title: String


    public var items: [PlaylistItem]?

    public var count: Int {
        get {
            items?.count ?? 0
        }
    }

    // PlayQueue
    public init() {
        self.id = UUID().uuidString
        self.title = "Play Queue"
        self.playlistType = .playqueue
    }

    // Playlist
    public init(_ playlist: PlaylistSummary) {
        self.id = playlist.id
        self.title = playlist.title
        self.playlistType = .playlist
    }

    // Album
    public init(_ album: AlbumSummary) {
        self.id = album.id
        self.title = album.title
        self.playlistType = .album
    }

    // Composition
    public init(_ composition: CompositionSummary) {
        self.id = composition.id
        self.title = composition.title
        self.playlistType = .composition
    }

    // Movement
    public init(_ movement: Movement) {
        self.id = movement.id
        self.title = movement.title
        self.playlistType = .movement
    }

    // Single
    public init(_ single: SingleSummary) {
        self.id = single.id
        self.title = single.title
        self.playlistType = .single
    }

    public init(playlistId: String, title: String) {
        self.id = playlistId
        self.title = title
        self.playlistType = .playlist
    }

    public init(playqueueId: String, title: String) {
        self.id = playqueueId
        self.title = title
        self.playlistType = .playqueue
    }

}

extension PlaylistItem: Codable {

}


