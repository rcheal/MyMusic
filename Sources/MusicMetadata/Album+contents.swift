//
//  Album+contents.swift
//  
//
//  Created by Robert Cheal on 10/31/20.
//

import Foundation

extension Album {

    public func getComposition(_ id: String) -> Composition? {
        for content in contents {
            if let composition = content.composition, composition.id == id {
                return composition
            }
        }
        return nil
    }
    
    public func getSingle(_ id: String) -> Single? {
        for content in contents {
            if let single = content.single, single.id == id {
                return single
            }
        }
        return nil
    }
    
    public func getMovement(_ id: String) -> Movement? {
        for content in contents {
            if let composition = content.composition,
               let movement = composition.getMovement(id) {
                return movement
            }
        }
        return nil
    }
    
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
        update()
    }
    
    public mutating func addSingle(_ single: Single) {
        let content = AlbumContent(single: single)
        contents.append(content)
        update()
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
    
    public mutating func replaceMovement(movement: Movement, compositionId: String) {
        let compIndex = contents.firstIndex(where:
            { (c) in
                c.id == compositionId
            }) ?? -1
        if compIndex >= 0 {
            contents[compIndex].composition?.replaceMovement(movement)
            updateDuration()
            sortContents()
        }
    }
    

}