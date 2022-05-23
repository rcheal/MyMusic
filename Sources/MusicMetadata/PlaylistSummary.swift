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

    public init(_ id: String, title: String, shared: Bool = false) {
        self.id = id
        self.title = title
        self.shared = shared
    }
    
    public init(_ playlist: Playlist) {
        id = playlist.id
        user = playlist.user
        title = playlist.title
        shared = playlist.shared
    }
    
}

extension PlaylistSummary: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case user
        case title
        case shared
    }
}
