//
//  Single+update.swift
//  
//
//  Created by Robert Cheal on 10/31/20.
//

import Foundation

extension Single {
    
    public mutating func update(_ album: Album, composition: Composition? = nil) {
        sortTitle = Album.sortedTitle(title).lowercased()
        sortArtist = Album.sortedPerson(artist ?? album.artist)?.lowercased()
        sortComposer = Album.sortedPerson(composer ?? album.composer)?.lowercased()
        compositionId = composition?.id
        albumId = album.id
    }

}
