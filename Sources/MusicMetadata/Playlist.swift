//
//  Playlist.swift
//  
//
//  Created by Robert Cheal on 12/21/20.
//

import Foundation

public enum PlaylistType: String, CaseIterable, Identifiable, Codable {
    case implicit, explicit

    public var id: Self { self }
}


public struct Playlist: Identifiable, Hashable {
    public var id: String
    
    public var user: String?
    public var title: String
    public var shared: Bool
    public var playlistType: PlaylistType = .explicit
    public var autoRepeat: Bool = false
    public var shuffle: Bool = false
    // Implicit playlist search fields
    public var artist: String?
    public var composer: String?
    public var genre: String?
    public var years: String?
    public var ratings: String?

    public var items: [PlaylistItem] = []

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
        case playlistType
        case autoRepeat
        case shuffle
        case artist
        case composer
        case genre
        case years
        case ratings
        case items
    }

}

extension Playlist {

    public var count: Int { items.count }

    public var trackCount: Int {
        get {
            var count = 0
            for item in items {
                count += item.trackCount
            }
            return count
        }
    }

    mutating public func append(_ item: PlaylistItem) {
            items.append(item)
    }

}
