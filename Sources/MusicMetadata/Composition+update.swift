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
        updateTrack()
        updateDuration()

    }
    
    public mutating func update() {
        sortTitle = Album.sortedTitle(title).lowercased()
        sortArtist = Album.sortedPerson(artist)?.lowercased()
        sortComposer = Album.sortedPerson(composer)?.lowercased()
        updateTrack()
        updateDuration()

    }
    
    mutating func updateTrack() {
        if let movement = movements.first {
            startDisk = movement.disk
            startTrack = movement.track
        }
    }
    
    mutating func updateDuration() {
        duration = 0
        for movement in movements {
            duration += movement.duration
        }
    }
    
}
