//
//  Album+art.swift
//  
//
//  Created by Robert Cheal on 12/6/20.
//

import Foundation

extension Album {
    public func artRef(_ index: Int) -> AlbumArtRef? {
        return _albumArt?.artRef(index)
    }
    
    public func frontArtRef() -> AlbumArtRef? {
        return _albumArt?.frontArtRef()
    }

    public func backArtRef() -> AlbumArtRef? {
        return _albumArt?.backArtRef()
    }
    
    public func artworkCount() -> Int {
        return _albumArt?.count ?? 0
    }
    
    public func artworkPageCount() -> Int {
        return _albumArt?.pageCount ?? 0
    }

    public func pageArtRef(_ seq: Int) -> AlbumArtRef? {
        return _albumArt?.pageArtRef(seq)
    }
    
    mutating public func addArt(_ artRef: AlbumArtRef) {
        albumArt.addArt(artRef)
    }
    
    mutating public func removeAllArt() {
        if _albumArt != nil {
            _albumArt!.removeAll()
        }
    }
    
    mutating public func removeFrontArt() {
        if _albumArt != nil {
            _albumArt!.removeFront()
        }
    }

    mutating public func removeBackArt() {
        if _albumArt != nil {
            _albumArt!.removeBack()
        }
    }
    
    mutating public func removePagesArt() {
        if _albumArt != nil {
            _albumArt!.removePages()
        }
    }
    
}
