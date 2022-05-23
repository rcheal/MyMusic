//
//  Playlist.swift
//  
//
//  Created by Robert Cheal on 12/21/20.
//

import Foundation

public struct Playlist: Identifiable, Hashable {
    public var id: String
    
    public var user: String?
    public var title: String
    public var shared: Bool
    public var autoRepeat: Bool = false
    public var shuffle: Bool = false
    
    public var content: PlaylistItem

    public init(_ title: String, user: String? = nil, shared: Bool? = nil) {
        let id = UUID().uuidString
        self.id = id
        self.title = title
        self.user = user
        if let shared = shared {
            self.shared = shared
        } else {
            self.shared = user == nil
        }
        content = PlaylistItem(playlistId: id, title: title)
    }

    mutating public func addContent(_ item: PlaylistItem) {
        if content.items == nil {
            content.items = [item]
        } else {
            content.items?.append(item)
        }
    }


}

extension Playlist: Codable {

    public enum CodingKeys: String, CodingKey {
        case id
        case user
        case title
        case shared
        case autoRepeat
        case content
    }

}
