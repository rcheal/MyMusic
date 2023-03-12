//
//  Playlist+contents.swift
//  
//
//  Created by Robert Cheal on 5/28/22.
//

import Foundation

/// Direction to move an item in a Playlist or PlaylistItem
public enum PlaylistItemMoveDirection {
    case up, down
}


extension Playlist {

    /// Count of items in playlist; 0 for implicit lists
    public var count: Int { items.count }

    /// counts of tracks contained in playlist; 0 for implicit lists
    public var trackCount: Int {
        get {
            var count = 0
            for item in items {
                count += item.trackCount
            }
            return count
        }
    }

    public func getAllItems() -> [PlaylistItem] {
        var allItems: [PlaylistItem] = []
        for item in items {
            allItems.append(contentsOf: item.getAllItems())
        }
        return allItems
    }

    /// Get flatted array of playlist items
    ///
    /// Traverses playlist tree and returns an array of tracks (singles and movements)
    /// - Returns: Array of ``PlaylistItem``
    public func getItems() -> [PlaylistItem] {
        let flattenedItems = flattened()
        return shuffle ? flattenedItems.shuffled() : flattenedItems
    }

    internal func flattened() -> [PlaylistItem] {
        var newItems: [PlaylistItem] = []
        for item in items {
            newItems.append(contentsOf: item.flattened())
        }
        return newItems
    }

    /// Get specific playlist item from playlist
    ///
    /// - Parameter id: id of PlaylistItem to retrieve
    /// - Returns: Optional ``PlaylistItem``
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

    /// Get parent item for specific child
    ///
    /// - Parameter id: id of child playlist item
    /// - Returns: Parent item found or nil
    public func getParentItem(_ id: String) -> PlaylistItem? {
        for item in items {
            if item.id == id {
                return nil
            }
            if let parentItem = item.getParentItem(id, parent: item) {
                return parentItem
            }
        }
        return nil
    }

    /// Get indices of specific item in playlist
    ///
    /// - Parameter id: id of playlist item to check
    /// - Returns: Array in indices indicating the position of the item within the playlist
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

    /// Add item to playlist
    ///
    /// - Parameter item: New item
    mutating public func addItem(_ item: PlaylistItem) {
        items.append(item)
    }

    /// Remove all items from playlist
    public mutating func removeAllItems() {
        items.removeAll()
    }


    /// Conditionally remove items from playlist
    ///
    /// - Parameter shouldBeRemoved: closure determining whether item should be removed
    public mutating func removeAllItems(where shouldBeRemoved: (PlaylistItem) throws -> Bool) rethrows {
        try items.removeAll(where: shouldBeRemoved)
        for (index, item) in items.enumerated() {
            var newItem = item
            try newItem.removeAllItems(where: shouldBeRemoved)
            self.items[index] = newItem
        }
    }

    /// Move item in playlist
    ///
    /// - Parameters:
    ///   - posArray: Index array showing position of item in playlist
    ///   - direction: Direction to move item - .up will swap with previous item, .down will swap with next item
    /// - Returns: true if move was performed; otherwise false
    public mutating func move(_ posArray: [Int], _ direction: PlaylistItemMoveDirection) -> Bool {
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
                return items[pos].move(posArray, direction)
            }
        }
        return false
    }

}
