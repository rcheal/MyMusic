//
//  Playlist.swift
//  
//
//  Created by Robert Cheal on 12/21/20.
//

import Foundation

public enum PlaylistType: String, CaseIterable, Identifiable, Codable {
    /// Playlist is explicitly defined list of albums, compostions, movements and/or singles
    case implicit
    /// Playlist is generated at play time from a list of search criteria
    case explicit

    public var id: Self { self }
}


/// A struct that stores a single playlist
///
/// A playlist is either an explicit list of albums, compositions, movements and/or singles
/// or an implicit list that is automatically created at playtime by searching the entire collection for
/// matching artists, composers, genres, years and or ratings
public struct Playlist: Identifiable, Hashable {
    /// UUID which identifies the playlist withing the collection
    public var id: String
    /// Optional username that owns the playlist.  If missing, the playlist is visible to all users
    public var user: String?
    /// Title of playlist
    public var title: String
    /// Flag indicating whether the playlist is visible to other users
    public var shared: Bool
    /// Type of playlist
    public var playlistType: PlaylistType = .explicit
    /// When playlist ends - start over
    public var autoRepeat: Bool = false
    /// Shuffle contents of playlist before playing
    public var shuffle: Bool = false
    // Implicit playlist search fields
    /// Comma separated list of artists to include in implicit playlist
    public var artist: String?
    /// Comma separated list of composers to include in implicit playlist
    public var composer: String?
    /// Comma separated list of genres to include in implicit playlist
    public var genre: String?
    /// Comma separated list of years or year ranges to include in implicit playlist
    public var years: String?
    /// Comma separated list of ratings to include in implicit playlist
    public var ratings: String?

    /// Items included in explicit playlist
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
