//
//  SingleListItem+update.swift
//  
//
//  Created by Robert Cheal on 12/6/20.
//

import Foundation

extension SingleListItem {
    
    public mutating func update() {
        sortTitle = Album.sortedTitle(title).lowercased()
        sortArtist = Album.sortedPerson(artist)?.lowercased()
        sortComposer = Album.sortedPerson(composer)?.lowercased()
    }

    public mutating func update(_ album: Album, composition: Composition? = nil) {
        sortTitle = Album.sortedTitle(title).lowercased()
        if let composition = composition {
            sortArtist = Album.sortedPerson(artist ?? composition.artist ?? album.artist)?.lowercased()
            sortComposer = Album.sortedPerson(composer ?? composition.composer ?? album.composer)?.lowercased()
            compositionId = composition.id
        }
        albumId = album.id
    }
}
