//
//  AlbumArtwork.swift
//  
//
//  Created by Robert Cheal on 12/6/20.
//

import Foundation

public struct AlbumArtwork: Hashable, Codable {
    
    internal var items: [AlbumArtRef]
    private(set) var pageCount: Int
    public var count: Int {
        items.count
    }
    
    public init() {
        pageCount = 0
        items = []
    }
    
    public func frontArtRef() -> AlbumArtRef? {
        if let artRef = items.first, artRef.type == .front {
            return artRef
        }
        return nil
    }

    public func backArtRef() -> AlbumArtRef? {
        if let artRef = items.first(where: { ref in
            ref.type == .back
        }) {
            return artRef
        }
        return nil
    }

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
    
    mutating public func removeAll() {
        items.removeAll()
        pageCount = 0
    }
    
    mutating public func removeFront() {
        items.removeAll() { (ref) -> Bool in
            ref.type == .front
        }
    }
    
    mutating public func removeBack() {
        items.removeAll() { (ref) -> Bool in
            ref.type == .back
        }
    }
    
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
