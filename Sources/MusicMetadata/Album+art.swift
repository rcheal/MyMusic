//
//  File.swift
//  
//
//  Created by Robert Cheal on 12/6/20.
//

import Foundation

extension Album {
    public func frontArtRef() -> AlbumArtRef? {
        return albumArt.frontArtRef()
    }

    public func backArtRef() -> AlbumArtRef? {
        return albumArt.backArtRef()
    }

    public func pageArtRef(_ seq: Int) -> AlbumArtRef? {
        return albumArt.pageArtRef(seq)
    }
    
    mutating public func addArt(_ artRef: AlbumArtRef) {
        albumArt.addArt(artRef)
    }
    
    mutating public func removeAllArt() {
        albumArt.removeAll()
    }
    
    mutating public func removeFrontArt() {
        albumArt.removeFront()
    }

    mutating public func removeBackArt() {
        albumArt.removeBack()
    }
    
    mutating public func removePagesArt() {
        albumArt.removePages()
    }
    
}
