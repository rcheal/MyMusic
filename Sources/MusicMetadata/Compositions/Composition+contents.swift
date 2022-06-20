//
//  Composition+contents.swift
//  
//
//  Created by Robert Cheal on 10/31/20.
//

import Foundation

extension Composition {

    /// Get specific movement from contents of ``Composition``
    ///
    /// - Parameter id: id of movement to retrieve
    /// - Returns: Optional ``Movement``
    public func getMovement(_ id: String) -> Movement? {
        for movement in movements {
            if movement.id == id {
                return movement
            }
        }
        return nil
    }

    /// Adds movement to composition
    ///
    /// - Parameter movement: Movement to add
    public mutating func addMovement(_ movement: Movement) {
        movements.append(movement)
        update()
    }

    /// Add movement from ``Single``
    ///
    /// Converts ``Single`` to ``Movement`` before calling `addMovement(movement:)`
    /// - Parameter single: Single to convert to movement and add
    public mutating func addMovement(from single: Single) {
        var movement = Movement(title: single.title, filename: single.filename, track: single.track, disk: single.disk)
        movement.duration = single.duration
        movement.subtitle = single.subtitle
        addMovement(movement)
    }

    /// Remove all movements from composition
    public mutating func removeAllMovements() {
        movements.removeAll()
    }

    /// Conditionally remove movements from composition
    ///
    /// - Parameter shouldBeRemoved: closure determining whether a specific movement should be removed
    public mutating func removeMovements(where shouldBeRemoved: (Movement) throws -> Bool) rethrows {
        try movements.removeAll(where: shouldBeRemoved)
    }

    /// Replaces a movement in the composition
    ///
    /// Replaces a movement with matching id
    /// - Parameter movement: New movement
    public mutating func replaceMovement(_ movement: Movement) {
        let movementIndex = movements.firstIndex(where:
            { (s) in
                s.id == movement.id
            }) ?? -1
        if movementIndex >= 0 {
            movements[movementIndex] = movement
            updateDuration()
            sortContents()
        }
    }

    /// Removes composition title from front of movement titles if it exists
    public mutating func normalizeTitles() {
        for index in movements.indices {
            let movementTitle = movements[index].title
            if movementTitle.hasPrefix(title) {
                movements[index].title = String(movementTitle.dropFirst(title.count))
            }
        }
    }
    
}
