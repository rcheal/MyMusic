//
//  CompositionSummary+update.swift
//  
//
//  Created by Robert Cheal on 12/6/20.
//

import Foundation

extension CompositionSummary {
    
    internal mutating func update() {
        sortTitle = Album.sortedTitle(title).lowercased()
        sortArtist = Album.sortedPerson(artist)?.lowercased()
        sortComposer = Album.sortedPerson(composer)?.lowercased()
    }
    
    internal mutating func update(_ album: Album) {
        sortTitle = Album.sortedTitle(title).lowercased()
        sortArtist = Album.sortedPerson(artist ?? album.artist)?.lowercased()
        sortComposer = Album.sortedPerson(composer ?? album.composer)?.lowercased()
        albumId = album.id
    }
    
}
