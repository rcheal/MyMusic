//
//  AlbumSummary+description.swift
//  
//
//  Created by Robert Cheal on 6/5/22.
//

import Foundation

extension AlbumSummary {
    
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
