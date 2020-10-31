//
//  Album+contents.swift
//  
//
//  Created by Robert Cheal on 10/31/20.
//

import Foundation

extension Album {
    
    public mutating func addContent(_ content: AlbumContent) {
        contents.append(content)
        if let composition = content.composition {
            duration += composition.duration
        } else if let single = content.single {
            duration += single.duration
        }
    }
    
    public mutating func removeAllContents() {
        contents.removeAll()
    }
    
    public mutating func removeAllContents(where shouldBeRemoved: (AlbumContent) throws -> Bool) rethrows {
        try contents.removeAll(where: shouldBeRemoved)
    }
    
    public mutating func replaceComposition(_ composition: Composition) {
        let compIndex = contents.firstIndex(where:
            { (c) in
                c.id == composition.id
            }) ?? -1
        if compIndex >= 0 {
            var content = contents[compIndex]
            content.composition = composition
            contents[compIndex] = content
            updateDuration()
        }
    }
    
    public mutating func replaceSingle(_ single: Single) {
        let singleIndex = contents.firstIndex(where:
            { (s) in
                s.id == single.id
            }) ?? -1
        if singleIndex >= 0 {
            var content = contents[singleIndex]
            content.single = single
            contents[singleIndex] = content
            updateDuration()
        }
    }
    
    public mutating func replaceSingle(_ single: Single, composition: Composition) {
        let compIndex = contents.firstIndex(where:
            { (c) in
                c.id == composition.id
            }) ?? -1
        if compIndex >= 0 {
            var comp = composition
            comp.replaceSingle(single)
            var content = contents[compIndex]
            content.composition = comp
            contents[compIndex] = content
            updateDuration()
        }
    }
    

}
