//
//  Playlist+contents.swift
//  
//
//  Created by Robert Cheal on 5/28/22.
//

import Foundation

public enum PlaylistItemSwapDirection {
    case up, down
}


extension Playlist {
    public func getItem(_ id: String) -> PlaylistItem? {
        for item in items {
            if item.id == id {
                return item
            }
            if let nestedItem = item.getItem(id) {
                return nestedItem
            }
        }
        return nil
    }

    public func getItemPosition(_ id: String) -> [Int] {
        for (index, item) in items.enumerated() {
            if item.id == id {
                return [index]
            }
            let value = item.getItemPosition(id)
            if value.count > 0 {
                var position = [index]
                position.append(contentsOf: value)
                return position
            }
        }
        return []
    }

    mutating public func addItem(_ item: PlaylistItem) {
        items.append(item)
    }

    public mutating func removeAllItems() {
        items.removeAll()
    }

    public mutating func removeAllItems(where shouldBeRemoved: (PlaylistItem) throws -> Bool) rethrows {
        try items.removeAll(where: shouldBeRemoved)
        for (index, item) in items.enumerated() {
            var newItem = item
            try newItem.removeAllItems(where: shouldBeRemoved)
            self.items[index] = newItem
        }
    }

    public mutating func swap(_ posArray: [Int], _ direction: PlaylistItemSwapDirection) -> Bool {
        guard !posArray.isEmpty else {
            return false
        }
        var posArray = posArray
        let pos = posArray.removeFirst()
        if posArray.isEmpty {
            let pos = (direction == .down) ? pos + 1 : pos
            if 1..<items.count ~= pos {
                items.swapAt(pos, pos-1)
                return true
            }
        } else {
            if 0..<items.count ~= pos {
                return items[pos].swap(posArray, direction)
            }
        }
        return false
    }

}
