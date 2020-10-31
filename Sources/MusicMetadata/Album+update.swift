//
//  Album+update.swift
//  
//
//  Created by Robert Cheal on 10/31/20.
//

import Foundation

extension Album {
    
    public mutating func update() {
        sortTitle = Album.sortedTitle(title).lowercased()
        sortArtist = Album.sortedPerson(artist)?.lowercased()
        sortComposer = Album.sortedPerson(composer)?.lowercased()
        
        for index in contents.indices {
            if var composition = contents[index].composition {
                composition.update(self)
                contents[index].composition = composition
                
            } else if var single = contents[index].single {
                single.update(self)
                contents[index].single = single
            }
        }
        
        updateTracks()
        updateDuration()

    }
    
    mutating func updateTracks() {
        for index in contents.indices {
            if var composition = contents[index].composition {
                composition.updateTrack()
                contents[index].disk = composition.startDisk
                contents[index].track = composition.startTrack
            } else if let single = contents[index].single {
                contents[index].disk = single.disk
                contents[index].track = single.track
            }
        }
    }
    
    mutating func updateDuration() {
        duration = 0
        for content in contents {
            if let single = content.single {
                duration += single.duration
            } else if let composition = content.composition {
                duration += composition.duration
            }
        }
    }

}
