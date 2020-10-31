//
//  Composition+sort.swift
//  
//
//  Created by Robert Cheal on 10/31/20.
//

import Foundation

extension Composition {
    
    public mutating func sortContents() {
        contents = contents.sorted { $0.track < $1.track }
    }
    
}
