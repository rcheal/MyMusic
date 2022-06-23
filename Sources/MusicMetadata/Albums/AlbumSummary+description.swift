//
//  AlbumSummary+description.swift
//  
//
//  Created by Robert Cheal on 6/5/22.
//

import Foundation

extension AlbumSummary {

    /// Computed short description of Album
    ///
    /// Prefers 'composer: title' for classical and 'title - artist' otherwise
    ///
    /// Specifically for classical:
    /// - if composer exists, then 'composer: title'
    /// - if artists exists, then 'artist: title'
    /// - otherwise, 'title'
    ///
    /// For non-classical:
    /// - if artist exists, then 'title - artist'
    /// - if composer exists then 'title - composer'
    /// - otherwise, 'title'
    public var description: String {
        if genre == "Classical" {
            if let composer = composer {
                return "\(composer): \(title)"
            } else if let artist = artist {
                return "\(artist): \(title)"
            } else {
                return title
            }
        } else {
            if let artist = artist {
                return "\(title) - \(artist)"
            } else if let composer = composer {
                return "\(title) - \(composer)"
            } else {
                return title
            }
        }
    }

}
