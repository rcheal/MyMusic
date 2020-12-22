//
//  Movement+update.swift
//  
//
//  Created by Robert Cheal on 12/22/20.
//

import Foundation

extension Movement {
    
    public mutating func update(_ album: Album? = nil, composition: Composition? = nil) {
        if let album = album {
            albumId = album.id
        }
        if let composition = composition {
            compositionId = composition.id
        }
    }

}
