//
//  Composition+contents.swift
//  
//
//  Created by Robert Cheal on 10/31/20.
//

import Foundation

extension Composition {
    
    public mutating func addMovement(_ movement: Movement) {
        movements.append(movement)
        duration += movement.duration
    }
    
    public mutating func addMovement(from single: Single) {
        var movement = Movement(track: single.track, title: single.title, filename: single.audiofileRef ?? "", disk: single.disk)
        movement.duration = single.duration
        movement.subtitle = single.subtitle
        addMovement(movement)
    }
    
    public mutating func removeAllMovements() {
        movements.removeAll()
    }
    
    public mutating func removeMovements(where shouldBeRemoved: (Movement) throws -> Bool) rethrows {
        try movements.removeAll(where: shouldBeRemoved)
    }

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
    
}
