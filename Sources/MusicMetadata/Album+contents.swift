//
//  Album+contents.swift
//  
//
//  Created by Robert Cheal on 10/31/20.
//

import Foundation

extension Album {

    internal mutating func addContent(_ content: AlbumContent) {
        contents.append(content)
        if let composition = content.composition {
            duration += composition.duration
        } else if let single = content.single {
            duration += single.duration
        }
    }
    
    public mutating func addComposition(_ composition: Composition) {
        let content = AlbumContent(composition: composition)
        contents.append(content)
        duration += composition.duration
    }
    
    public mutating func addSingle(_ single: Single) {
        let content = AlbumContent(single: single)
        contents.append(content)
        duration += single.duration
    }
    
    public mutating func removeAllContents() {
        contents.removeAll()
    }
    
    public mutating func removeAllSingles() {
        removeAllContents() { (content) -> Bool in
            content.single != nil
        }
    }
    
    public mutating func removeAllSingles(where shouldBeRemoved: (Single) throws -> Bool) rethrows {
        try removeAllContents() { (content) -> Bool in
            if let single = content.single {
                return  try shouldBeRemoved(single)
            }
            return false
        }
    }
    
    public mutating func removeAllCompositions() {
        removeAllContents() { (content) -> Bool in
            content.composition != nil
        }
    }

    public mutating func removeAllCompositions(where shouldBeRemoved: (Composition) throws -> Bool) rethrows {
        try removeAllContents() { (content) -> Bool in
            if let composition = content.composition {
                return try shouldBeRemoved(composition)
            }
            return false
        }
    }
    
    private mutating func removeAllContents(where shouldBeRemoved: (AlbumContent) throws -> Bool) rethrows {
        try contents.removeAll(where: shouldBeRemoved)
    }
    
    public mutating func replaceComposition(_ composition: Composition) {
        let compIndex = contents.firstIndex(where:
            { (c) in
                c.id == composition.id
            }) ?? -1
        if compIndex >= 0 {
            let content = AlbumContent(composition: composition)
            contents[compIndex] = content
            updateDuration()
            sortContents()
        }
    }
    
    public mutating func replaceSingle(_ single: Single) {
        let singleIndex = contents.firstIndex(where:
            { (s) in
                s.id == single.id
            }) ?? -1
        if singleIndex >= 0 {
            let content = AlbumContent(single: single)
            contents[singleIndex] = content
            updateDuration()
            sortContents()
        }
    }
    
    public mutating func replaceSingle(single: Single, compositionId: String) {
        let compIndex = contents.firstIndex(where:
            { (c) in
                c.id == compositionId
            }) ?? -1
        if compIndex >= 0 {
            contents[compIndex].composition?.replaceSingle(single)
            updateDuration()
            sortContents()
        }
    }
    

}
