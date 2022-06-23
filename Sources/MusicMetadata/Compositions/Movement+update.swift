//
//  Movement+update.swift
//  
//
//  Created by Robert Cheal on 12/22/20.
//

import Foundation

extension Movement {
    
    internal mutating func update(_ album: Album? = nil, composition: Composition? = nil) {
        if let album = album {
            albumId = album.id
        }
        if let composition = composition {
            compositionId = composition.id
        }
    }

    internal mutating func update(disk: Int?) {
        self.disk = disk
    }
    
    internal mutating func update(track: Int, disk: Int? = nil) {
        self.track = track
        if let disk = disk {
            self.disk = disk
        }
    }
}
