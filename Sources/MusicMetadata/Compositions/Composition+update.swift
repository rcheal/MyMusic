//
//  Composition+update.swift
//  
//
//  Created by Robert Cheal on 10/31/20.
//

import Foundation

extension Composition {
    
    internal mutating func update(_ album: Album) {
        sortTitle = Album.sortedTitle(title).lowercased()
        sortArtist = Album.sortedPerson(artist ?? album.artist)?.lowercased()
        sortComposer = Album.sortedPerson(composer ?? album.composer)?.lowercased()
        albumId = album.id
        
        for index in movements.indices {
            movements[index].update(album, composition: self)
        }
        
        updateTrack()
        updateDuration()

    }
    
    internal mutating func update() {
        sortTitle = Album.sortedTitle(title).lowercased()
        sortArtist = Album.sortedPerson(artist)?.lowercased()
        sortComposer = Album.sortedPerson(composer)?.lowercased()
        updateTrack()
        updateDuration()

    }
    
    internal mutating func updateTrack() {
        if let movement = movements.first {
            startDisk = movement.disk
            startTrack = movement.track
        }
    }
    
    internal mutating func updateMovementDisks() {
        for index in movements.indices {
            movements[index].update(disk: startDisk)
        }
    }
    
    internal mutating func updateMovementTracks() {
        var track = startTrack
        for index in movements.indices {
            movements[index].update(track: track)
            track += 1
        }
    }
    
    internal mutating func updateDuration() {
        duration = 0
        for movement in movements {
            duration += movement.duration
        }
    }
    
}
