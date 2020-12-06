//
//  AlbumArtwork.swift
//  
//
//  Created by Robert Cheal on 12/6/20.
//

import Foundation

public struct AlbumArtwork: Hashable, Codable {
    
    internal var items: [AlbumArtRef]
    
    public init() {
        items = []
    }
    
    public func frontArtRef() -> AlbumArtRef? {
        for artRef in items {
            if artRef.type == .front {
                return artRef
            }
        }
        return nil
    }

    public func backArtRef() -> AlbumArtRef? {
        for artRef in items {
            if artRef.type == .back {
                return artRef
            }
        }
        return nil
    }

    public func pageArtRef(_ seq: Int?) -> AlbumArtRef? {
        for artRef in items {
            if artRef.type == .page && artRef.seq == seq {
                return artRef
            }
        }
        return nil
    }
    
    mutating public func addArt(_ artRef: AlbumArtRef) {
        switch artRef.type {
        case .front:
            if let _ = frontArtRef() { } else {
                items.append(artRef)
            }
        case .back:
            if let _ = backArtRef() { } else {
                items.append(artRef)
            }
        case .page:
            if let _ = pageArtRef(artRef.seq) { } else {
                items.append(artRef)
            }
        }
    }
    
    mutating public func deleteArt(_ artRef: AlbumArtRef) {
        items.removeAll { (ref) -> Bool in
            ref.type == artRef.type && ref.seq == artRef.seq
        }
    }
}
