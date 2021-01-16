//
//  Playlist.swift
//  
//
//  Created by Robert Cheal on 12/21/20.
//

import Foundation

public struct PlaylistItem: Identifiable, Hashable {
    public var id: String
    public var playlistType: PlaylistItemType
}

public struct Playlist: Identifiable, Hashable {
    public var id: String
    
    public var title: String
    public var shared: Bool
    
    public var nextItemIndex: Int
    public var items: [PlaylistItem]
    public var randomItems: [PlaylistItem]?
    
    init(_ title: String, shared: Bool = false) {
        id = UUID().uuidString
        self.title = title
        self.shared = shared
        nextItemIndex = -1
        items = []
    }

}

extension PlaylistItem: Codable {
    
}

extension Playlist: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case id
        case title
        case shared
        case nextItemIndex
        case items
    }

}
