//
//  Composition+update.swift
//  
//
//  Created by Robert Cheal on 10/31/20.
//

import Foundation

extension Composition {
    
    public mutating func update(_ album: Album) {
        sortTitle = Album.sortedTitle(title).lowercased()
        sortArtist = Album.sortedPerson(artist ?? album.artist)?.lowercased()
        sortComposer = Album.sortedPerson(composer ?? album.composer)?.lowercased()
        albumId = album.id
        for index in contents.indices {
            contents[index].update(album, composition: self)
        }
        updateTrack()
        updateDuration()

    }
    
    mutating func updateTrack() {
        if let single = contents.first {
            startDisk = single.disk
            startTrack = single.track
        }
    }
    
    mutating func updateDuration() {
        duration = 0
        for single in contents {
            duration += single.duration
        }
    }
    
}
