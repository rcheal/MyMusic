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
    
    public var content: [PlaylistItem] = []

    public init(_ title: String,
                user: String? = nil,
                shared: Bool? = nil) {
        let id = UUID().uuidString
        self.id = id
        self.title = title
        self.user = user
        if let shared = shared {
            self.shared = shared
        } else {
            self.shared = user == nil
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

extension Playlist {

    public var count: Int { content.count }

    public var trackCount: Int {
        get {
            var count = 0
            for item in content {
                count += item.trackCount
            }
            return count
        }
    }

    mutating public func append(_ item: PlaylistItem) {
            content.append(item)
    }

}
