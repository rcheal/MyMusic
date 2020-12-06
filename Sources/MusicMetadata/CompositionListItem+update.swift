//
//  File.swift
//  
//
//  Created by Robert Cheal on 12/6/20.
//

import Foundation

extension CompositionListItem {
    
    public mutating func update() {
        sortTitle = Album.sortedTitle(title).lowercased()
        sortArtist = Album.sortedPerson(artist)?.lowercased()
        sortComposer = Album.sortedPerson(composer)?.lowercased()
    }
    
    public mutating func update(_ album: Album) {
        sortTitle = Album.sortedTitle(title).lowercased()
        sortArtist = Album.sortedPerson(artist ?? album.artist)?.lowercased()
        sortComposer = Album.sortedPerson(composer ?? album.composer)?.lowercased()
        albumId = album.id
    }
    
}
