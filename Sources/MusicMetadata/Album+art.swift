//
//  File.swift
//  
//
//  Created by Robert Cheal on 12/6/20.
//

import Foundation

extension Album {
    public func frontArtRef() -> AlbumArtRef? {
        for artRef in albumArtRef {
            if artRef.type == .front {
                return artRef
            }
        }
        return nil
    }

    public func backArtRef() -> AlbumArtRef? {
        for artRef in albumArtRef {
            if artRef.type == .back {
                return artRef
            }
        }
        return nil
    }

    public func pageArtRef(_ seq: Int?) -> AlbumArtRef? {
        for artRef in albumArtRef {
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
                albumArtRef.append(artRef)
            }
        case .back:
            if let _ = backArtRef() { } else {
                albumArtRef.append(artRef)
            }
        case .page:
            if let _ = pageArtRef(artRef.seq) { } else {
                albumArtRef.append(artRef)
            }
        }
    }
    
    mutating public func deleteArt(_ artRef: AlbumArtRef) {
        albumArtRef.removeAll { (ref) -> Bool in
            ref.type == artRef.type && ref.seq == artRef.seq
        }
    }
}
