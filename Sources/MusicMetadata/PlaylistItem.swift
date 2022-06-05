//
//  PlaylistItem.swift
//  
//
//  Created by Robert Cheal on 5/23/22.
//

import Foundation

public enum PlaylistItemType: String, Codable {
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

    // Album
    public init(_ album: AlbumSummary, items: [PlaylistItem]? = nil) {
        self.id = album.id
        self.title = album.title
        self.playlistType = .album
        self.items = items
    }

    // Composition
    public init(_ composition: CompositionSummary, items: [PlaylistItem]? = nil) {
        self.id = composition.id
        self.title = composition.title
        self.playlistType = .composition
        self.items = items
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
        if single.genre == "Classical" {
            if let composer = single.composer {
                self.title = "\(composer): \(single.title)"
            } else if let artist = single.artist {
                self.title = "\(artist): \(single.title)"
            } else {
                self.title = single.title
            }
        } else {
            if let artist = single.artist {
                self.title = "\(single.title) - \(artist)"
            } else if let composer = single.composer {
                self.title = "\(single.title) - \(composer)"
            } else {
                self.title = single.title
            }
        }
        self.playlistType = .single
    }

    // Album
    public init(album: String, items: [PlaylistItem]? = nil) {
        self.id = UUID().uuidString
        self.title = album
        self.playlistType = .album
        self.items = items
    }

    // Composition
    public init(composition: String, items: [PlaylistItem]? = nil) {
        self.id = UUID().uuidString
        self.title = composition
        self.playlistType = .composition
        self.items = items
    }

    // Movement
    public init(movement: String) {
        self.id = UUID().uuidString
        self.title = movement
        self.playlistType = .movement
    }

    // Single
    public init(single: String) {
        self.id = UUID().uuidString
        self.title = single
        self.playlistType = .single
    }

}

extension PlaylistItem: Codable {

    public enum CodingKeys: String, CodingKey {
        case id
        case title
        case playlistType
        case items
    }
}

extension PlaylistItem {

    public var count: Int {
        get {
            items?.count ?? 0
        }
    }

    public var trackCount: Int {
        get {
            switch playlistType {
            case .single, .movement:
                return 1
            default:
                var count = 0
                if let items = items {
                    for item in items {
                        count += item.trackCount
                    }
                }
                return count
            }
        }
    }

}


