//
//  AlbumArtwork.swift
//  
//
//  Created by Robert Cheal on 12/6/20.
//

import Foundation

/// Descriptions of all artwork files associated with the Album
public struct AlbumArtwork: Hashable, Codable {

    /// References to all artwork files
    internal var items: [AlbumArtRef]
    /// Count of all `.page` files
    public private(set) var pageCount: Int
    /// Count of all artwork items
    public var count: Int {
        items.count
    }
    
    public init() {
        pageCount = 0
        items = []
    }

    /// Get reference to artwork file
    ///
    /// - Parameter index: array index for artwork desired
    /// - Returns: Optional ``AlbumArtRef`` referencing artwork file
    public func artRef(_ index: Int) -> AlbumArtRef? {
        if index < 0 || index >= count {
            return nil
        } else {
            return items[index]
        }
    }

    /// Get reference to front cover art
    ///
    /// - Returns: Optional ``AlbumArtRef`` referencing front cover art file
    public func frontArtRef() -> AlbumArtRef? {
        if let artRef = items.first, artRef.type == .front {
            return artRef
        }
        return nil
    }


    /// Get reference to back cover art
    ///
    /// - Returns: Optional ``AlbumArtRef`` pointing to back cover art file
   public func backArtRef() -> AlbumArtRef? {
        if let artRef = items.first(where: { ref in
            ref.type == .back
        }) {
            return artRef
        }
        return nil
    }

    /// Get reference to page artwork
    ///
    /// - Parameter seq: Page number
    /// - Returns: Optional ``AlbumArtRef`` referencing page file
    public func pageArtRef(_ seq: Int) -> AlbumArtRef? {
        let index = seq - 1 + count - pageCount
        guard (0..<items.count).contains(index) else {
            return nil
        }
        let artRef = items[index]
        if artRef.type == .page {
            return artRef
        }
        return nil
    }

    /// Add artwork to album
    ///
    /// Supplied artRef is inserted in items array.  `.front` art is inserted at beginning of array;
    /// `.back` art is inserted following any `.front` art while `.page` art is inserted at end of array
    ///
    /// - Parameter artRef: ``AlbumArtRef`` describing artwork to be added
    mutating public func addArt(_ artRef: AlbumArtRef) {
        switch artRef.type {
        case .front:
            if let _ = frontArtRef() { } else {
                items.insert(artRef, at: 0)
            }
        case .back:
            if let _ = backArtRef() { } else {
                if let _ = frontArtRef() {
                    items.insert(artRef, at: 1)
                } else {
                    items.insert(artRef, at: 0)
                }
            }
        case .page:
            pageCount += 1
            var tempArtRef = artRef
            tempArtRef.seq = pageCount
            items.append(tempArtRef)
        }
    }

    /// Removes all items.
    mutating public func removeAll() {
        items.removeAll()
        pageCount = 0
    }

    /// Removes front art
    mutating public func removeFront() {
        items.removeAll() { (ref) -> Bool in
            ref.type == .front
        }
    }

    /// Removes back art
    mutating public func removeBack() {
        items.removeAll() { (ref) -> Bool in
            ref.type == .back
        }
    }

    /// Removes all `.page` art
    mutating public func removePages() {
        items.removeAll() { (ref) -> Bool in
            let removed = ref.type == .page
            if removed {
                pageCount -= 1
            }
            return removed
        }
    }
        
}
