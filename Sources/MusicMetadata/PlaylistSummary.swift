//
//  PlaylistSummary.swift
//  
//
//  Created by Robert Cheal on 1/16/21.
//

import Foundation

public struct PlaylistSummary: Identifiable, Hashable {
    public var id: String
    public var user: String?
    public var title: String
    public var shared: Bool
    // Sort fields
    public var sortTitle: String?

    public init(_ id: String, title: String, shared: Bool = false) {
        self.id = id
        self.title = title
        self.shared = shared
        self.sortTitle = Album.sortedTitle(title).lowercased()
    }
    
    public init(_ playlist: Playlist) {
        id = playlist.id
        user = playlist.user
        title = playlist.title
        shared = playlist.shared
        sortTitle = Album.sortedTitle(playlist.title).lowercased()
    }
    
}

extension PlaylistSummary: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case user
        case title
        case shared
        case sortTitle
    }
}
