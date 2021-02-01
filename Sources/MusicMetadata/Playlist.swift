//
//  Playlist.swift
//  
//
//  Created by Robert Cheal on 12/21/20.
//

import Foundation

public enum PlaylistItemType: String, Codable {
    case album
    case composition
    case movement
    case single
    case playlist
}

public struct PlaylistItem: Identifiable, Hashable {
    public var id: String
    public var playlistType: PlaylistItemType
    
    public init(id: String, playlistType: PlaylistItemType) {
        self.id = id
        self.playlistType = playlistType
    }
}

public struct Playlist: Identifiable, Hashable {
    public var id: String
    
    public var user: String?
    public var title: String
    public var shared: Bool
    
    public var nextItemIndex: Int?
    public var items: [PlaylistItem]
    public var orderedItems: [PlaylistItem]?
    
    public init(_ title: String, shared: Bool = false) {
        id = UUID().uuidString
        self.title = title
        self.shared = shared
        items = []
    }

}

extension PlaylistItem: Codable {
    
}

extension Playlist: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case id
        case user
        case title
        case shared
        case nextItemIndex
        case items
    }

}
