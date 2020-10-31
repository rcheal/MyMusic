//
//  Composition+contents.swift
//  
//
//  Created by Robert Cheal on 10/31/20.
//

import Foundation

extension Composition {
    
    public mutating func addContent(_ content: Single) {
        contents.append(content)
        duration += content.duration
    }
    
    public mutating func removeAllContents() {
        contents.removeAll()
    }
    
    public mutating func removeAllContents(where shouldBeRemoved: (Single) throws -> Bool) rethrows {
        try contents.removeAll(where: shouldBeRemoved)
    }

    public mutating func replaceSingle(_ single: Single) {
        let singleIndex = contents.firstIndex(where:
            { (s) in
                s.id == single.id
            }) ?? -1
        if singleIndex >= 0 {
            contents[singleIndex] = single
        }
    }
    
}
