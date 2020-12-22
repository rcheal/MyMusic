//
//  SingleListItem+update.swift
//  
//
//  Created by Robert Cheal on 12/6/20.
//

import Foundation

extension SingleListItem {
    
    public mutating func update(_ album: Album? = nil) {
        sortTitle = Album.sortedTitle(title).lowercased()
        if let album = album {
            sortArtist = Album.sortedPerson(artist ?? album.artist)?.lowercased()
            sortComposer = Album.sortedPerson(composer ?? album.composer)?.lowercased()
        } else {
            sortArtist = Album.sortedPerson(artist)?.lowercased()
            sortComposer = Album.sortedPerson(composer)?.lowercased()
        }
    }

}
