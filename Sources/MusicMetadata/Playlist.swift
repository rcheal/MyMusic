//
//  Playlist.swift
//  
//
//  Created by Robert Cheal on 12/21/20.
//

import Foundation

public struct PlaylistItem: Identifiable, Hashable {
    public var id: String
    public var playlistType: MetadataType
}

public struct Playlist: Identifiable, Hashable {
    public var id: String
    
    public var title: String
        
    public var nextItemIndex: Int
    public var items: [PlaylistItem]
    public var randomItems: [PlaylistItem]?
    
    init(_ title: String) {
        id = UUID().uuidString
        self.title = title
        nextItemIndex = -1
        items = []
    }

}

extension PlaylistItem: Codable {
    
}

extension Playlist: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case nextItemIndex
        case items
    }

}
