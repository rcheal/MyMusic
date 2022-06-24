//
//  Album+art.swift
//  
//
//  Created by Robert Cheal on 12/6/20.
//

import Foundation

extension Album {

    /// Get reference to artwork file
    ///
    /// - Parameter index: array index for artwork desired
    /// - Returns: Optional ``AlbumArtRef`` referencing artwork file
    public func artRef(_ index: Int) -> AlbumArtRef? {
        return _albumArt?.artRef(index)
    }

    /// Get reference to front cover art
    ///
    /// - Returns: Optional ``AlbumArtRef`` referencing front cover art file
    public func frontArtRef() -> AlbumArtRef? {
        return _albumArt?.frontArtRef()
    }

    /// Get reference to back cover art
    ///
    /// - Returns: Optional ``AlbumArtRef`` pointing to back cover art file
    public func backArtRef() -> AlbumArtRef? {
        return _albumArt?.backArtRef()
    }

    /// Determine number of artwork files associated with album
    ///
    /// - Returns: Count of all artwork files associated with the album
    public func artworkCount() -> Int {
        return _albumArt?.count ?? 0
    }

    /// Determine number of artwork pages (not including front and back) associated with album
    ///
    /// - Returns: Count of all artwork pages associated with the album
    public func artworkPageCount() -> Int {
        return _albumArt?.pageCount ?? 0
    }

    /// Get reference to page artwork
    ///
    /// - Parameter seq: Page number
    /// - Returns: Optional ``AlbumArtRef`` referencing page file
    public func pageArtRef(_ seq: Int) -> AlbumArtRef? {
        return _albumArt?.pageArtRef(seq)
    }
    
    /// Add artwork to album
    ///
    /// Supplied artRef is inserted in items array.  `.front` art is inserted at beginning of array;
    /// `.back` art is inserted following any `.front` art while `.page` art is inserted at end of array
    ///
    /// - Parameter artRef: ``AlbumArtRef`` describing artwork to be added
    /// Removes front art
    mutating public func addArt(_ artRef: AlbumArtRef) {
        albumArt.addArt(artRef)
    }
    
    /// Removes all artwork.
    mutating public func removeAllArt() {
        if _albumArt != nil {
            _albumArt!.removeAll()
        }
    }
    
    /// Removes front art
    mutating public func removeFrontArt() {
        if _albumArt != nil {
            _albumArt!.removeFront()
        }
    }

    // Removes back art
    mutating public func removeBackArt() {
        if _albumArt != nil {
            _albumArt!.removeBack()
        }
    }
    
    /// Removes all `.page` art
    mutating public func removePagesArt() {
        if _albumArt != nil {
            _albumArt!.removePages()
        }
    }
    
}
