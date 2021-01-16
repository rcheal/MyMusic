//
//  AlbumSummary+update.swift
//  
//
//  Created by Robert Cheal on 12/6/20.
//

import Foundation

extension AlbumSummary {
    
    public mutating func update() {
        sortTitle = Album.sortedTitle(title).lowercased()
        sortArtist = Album.sortedPerson(artist)?.lowercased()
        sortComposer = Album.sortedPerson(composer)?.lowercased()
    }
    
}
