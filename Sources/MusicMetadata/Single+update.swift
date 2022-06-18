//
//  Single+update.swift
//  
//
//  Created by Robert Cheal on 10/31/20.
//

import Foundation

extension Single {
    
    internal mutating func update(composition: Composition? = nil) {
        sortTitle = Album.sortedTitle(title).lowercased()
        if let composition = composition {
            sortArtist = Album.sortedPerson((artist ?? composition.artist)?.lowercased())
            sortComposer = Album.sortedPerson((composer ?? composition.composer)?.lowercased())
            compositionId = composition.id
        } else {
            if let artist = artist {
                sortArtist = Album.sortedPerson(artist)?.lowercased()
            }
            if let composer = composer {
                sortComposer = Album.sortedPerson(composer)?.lowercased()
            }
        }
    }
    
    internal mutating func update(_ album: Album, composition: Composition? = nil) {
        sortTitle = Album.sortedTitle(title).lowercased()
        if let composition = composition {
            sortArtist = Album.sortedPerson((artist ?? composition.artist) ?? album.artist)?.lowercased()
            sortComposer = Album.sortedPerson((composer ?? composition.composer) ?? album.composer)?.lowercased()
            compositionId = composition.id
        } else {
            sortArtist = Album.sortedPerson(artist ?? album.artist)?.lowercased()
            sortComposer = Album.sortedPerson(composer ?? album.composer)?.lowercased()
            compositionId = nil
        }
        albumId = album.id
    }

}
