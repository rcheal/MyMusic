//
//  Album+update.swift
//  
//
//  Created by Robert Cheal on 10/31/20.
//

import Foundation

extension Album {

    /// Updates various album fields
    ///
    /// The following metadata fields are updated
    /// - sortTitle (generated from title if missing)
    /// - sortArtist (generated from artist if missing)
    /// - sortComposer (generated from composer if missing
    ///
    /// Single and Composition content is also updated by calling .update(self)
    ///
    /// Tracks are resequenced  to remove any gaps or duplicates
    ///
    /// Durations are recalulated from content
    public mutating func update() {
        if let sortTitle = sortTitle,
           let first = sortTitle.first, first.isUppercase {} else {
            sortTitle = Album.sortedTitle(title).lowercased()
        }
        if let sortArtist = sortArtist,
           let first = sortArtist.first, first.isUppercase {} else {
            sortArtist = Album.sortedPerson(artist)?.lowercased()
        }
        if let sortComposer = sortComposer,
           let first = sortComposer.first, first.isUppercase {} else {
            sortComposer = Album.sortedPerson(composer)?.lowercased()
        }
        
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
    
    mutating internal func updateTracks() {
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
    
    mutating internal func updateDuration() {
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
