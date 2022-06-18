//
//  Composition+sort.swift
//  
//
//  Created by Robert Cheal on 10/31/20.
//

import Foundation

extension Composition {

    /// Sort movements by disk and track
    public mutating func sortContents() {
        movements = movements.sorted {
            let diska = $0.disk ?? 1
            let diskb = $1.disk ?? 1
            if diska == diskb {
                return $0.track < $1.track
            }
            return diska < diskb
        }
        updateTrack()
    }
    
}
