//
//  Album+contents.swift
//  
//
//  Created by Robert Cheal on 10/31/20.
//

import Foundation

extension Album {

    /// Get specific compositiion from contents of album
    ///
    /// - Parameter id: id of composition to retrieve
    /// - Returns: Optional ``Composition``
    public func getComposition(_ id: String) -> Composition? {
        for content in contents {
            if let composition = content.composition, composition.id == id {
                return composition
            }
        }
        return nil
    }

    /// Get specific single from contents of album
    ///
    /// - Parameter id: id of single to retrieve
    /// - Returns: Optional ``Single``
    public func getSingle(_ id: String) -> Single? {
        for content in contents {
            if let single = content.single, single.id == id {
                return single
            }
        }
        return nil
    }

    /// Get specific movement from contents of album
    ///
    /// Searches for a specific movement within each composition contained in album
    /// - Parameter id: id of movement to retreive
    /// - Returns: Optional ``Movement``
    public func getMovement(_ id: String) -> Movement? {
        for content in contents {
            if let composition = content.composition,
               let movement = composition.getMovement(id) {
                return movement
            }
        }
        return nil
    }

    /// Add content (``AlbumContent``) to album
    ///
    /// Add new content and adjust duration of album to account for duration of new content
    /// - Parameter content: album content consisting of either ``Single`` or ``Composition``
    internal mutating func addContent(_ content: AlbumContent) {
        contents.append(content)
        if let composition = content.composition {
            duration += composition.duration
        } else if let single = content.single {
            duration += single.duration
        }
    }

    /// Add composition to album
    ///
    /// Creates new ``AlbumContent`` containing composition, adds it to the album and calls
    /// ``update()`` to maintain album consistency
    /// - Parameter composition: Composition to add.
    public mutating func addComposition(_ composition: Composition) {
        let content = AlbumContent(composition: composition)
        contents.append(content)
        update()
    }

    /// Add single to album
    ///
    /// Creates new ``AlbumContent`` containing single, adds it to the album and calls
    /// ``update()`` to maintain album consistency
    /// - Parameter single: Singles to be added
    public mutating func addSingle(_ single: Single) {
        let content = AlbumContent(single: single)
        contents.append(content)
        update()
    }

    /// Removes all content from album
    public mutating func removeAllContents() {
        contents.removeAll()
    }

    /// Removes all singles from album
    public mutating func removeAllSingles() {
        removeAllContents() { (content) -> Bool in
            content.single != nil
        }
    }

    /// Conditionally removes singles from album
    ///
    /// - Parameter shouldBeRemoved: closure determining whether a specific single should be removed
    public mutating func removeAllSingles(where shouldBeRemoved: (Single) throws -> Bool) rethrows {
        try removeAllContents() { (content) -> Bool in
            if let single = content.single {
                return  try shouldBeRemoved(single)
            }
            return false
        }
    }

    /// Removes all compositions from album
    public mutating func removeAllCompositions() {
        removeAllContents() { (content) -> Bool in
            content.composition != nil
        }
    }

    /// Conditionally removes compositions from album
    ///
    /// - Parameter shouldBeRemoved: closure determining whether a specific single should be removed
    public mutating func removeAllCompositions(where shouldBeRemoved: (Composition) throws -> Bool) rethrows {
        try removeAllContents() { (content) -> Bool in
            if let composition = content.composition {
                return try shouldBeRemoved(composition)
            }
            return false
        }
    }

    /// Conditionally removes contents from album
    ///
    /// - Parameter shouldBeRemoved: closure determining whether content should be removed
    private mutating func removeAllContents(where shouldBeRemoved: (AlbumContent) throws -> Bool) rethrows {
        try contents.removeAll(where: shouldBeRemoved)
    }

    /// Replace a composition in the album
    ///
    /// Replaces a composition with a matching id.
    /// - Parameter composition: New composition
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

    /// Replaces a single in the album
    ///
    /// Replaces a single with a matching id.
    /// - Parameter single: New single
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

    /// Replaces a movement in the album
    ///
    /// Replaces a movement with a matching id.
    /// - Parameters:
    ///   - movement: New movement
    ///   - compositionId: Id of composition containing movement
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
