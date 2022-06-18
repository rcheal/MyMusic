//
//  PlaylistItem+contents.swift
//  
//
//  Created by Robert Cheal on 5/27/22.
//

import Foundation

extension PlaylistItem {

    /// Count of first level nested playlist items
    public var count: Int {
        get {
            items?.count ?? 0
        }
    }

    /// Count of tracks in item
    public var trackCount: Int {
        get {
            switch playlistType {
            case .single, .movement:
                return 1
            default:
                var count = 0
                if let items = items {
                    for item in items {
                        count += item.trackCount
                    }
                }
                return count
            }
        }
    }

    /// Get specific child playlist item
    ///
    /// - Parameter id: id of PlaylistItem to retrieve
    /// - Returns: ``PlaylistItem``
    public func getItem(_ id: String) -> PlaylistItem? {
        if let items = items {
            for item in items {
                if item.id == id {
                    return item
                }
                if let nestedItem = item.getItem(id) {
                    return nestedItem
                }
            }
        }
        return nil
    }

    /// Get indices of specific child playlist item
    ///
    /// - Parameter id: id of playlist item to check
    /// - Returns: Array of indices indicating the position of the item within self
    public func getItemPosition(_ id: String) -> [Int] {
        if let items = items {
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
        }
        return []
    }

    internal func flattened() -> [PlaylistItem] {
        if let items = items {
            var newItems: [PlaylistItem] = []
            for item in items {
                if playlistType == .composition {
                    var item = item
                    item.title = title + ", " + item.title
                    newItems.append(contentsOf: item.flattened())
                } else {
                    newItems.append(contentsOf: item.flattened())
                }
            }
            return newItems
        }
        else {
            return [self]
        }
    }

    /// Add child item
    ///
    /// - Parameter item: New item
    mutating public func addItem(_ item: PlaylistItem) {
        if var items = items {
            items.append(item)
            self.items = items
        } else {
            self.items = [item]
        }
    }

    /// Remove all child items
    public mutating func removeAllItems() {
        items?.removeAll()
    }

    /// Conditionally remove child items
    ///
    /// - Parameter shouldBeRemoved: closure determining whether item should be removed
    public mutating func removeAllItems(where shouldBeRemoved: (PlaylistItem) throws -> Bool) rethrows {
        try items?.removeAll(where: shouldBeRemoved)
        if let items = items {
            for (index, item) in items.enumerated() {
                var newItem = item
                try newItem.removeAllItems(where: shouldBeRemoved)
                self.items![index] = newItem
            }
        }
    }

    /// Move child item within parent item
    ///
    /// - Parameters:
    ///   - posArray: Index array showing position of item within this item
    ///   - direction: Direction to move item - .up will swal with previous item, .down will swap with next item
    /// - Returns: true if move was performed; otherwise false
    public mutating func move(_ posArray: [Int], _ direction: PlaylistItemMoveDirection) -> Bool {
        guard !posArray.isEmpty else {
            return false
        }
        var posArray = posArray
        let pos = posArray.removeFirst()
        if posArray.isEmpty {
            if var items = items {
                let pos = (direction == .down) ? pos + 1 : pos
                if 1..<items.count ~= pos {
                    items.swapAt(pos, pos-1)
                    self.items = items
                    return true
                }
            }
        } else {
            if var items = items {
                if 0..<items.count ~= pos {
                    if items[pos].move(posArray, direction) {
                        self.items = items
                        return true
                    }
                }
            }
        }
        return false
    }

}
