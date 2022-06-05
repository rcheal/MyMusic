//
//  PlaylistItem+contents.swift
//  
//
//  Created by Robert Cheal on 5/27/22.
//

import Foundation

extension PlaylistItem {

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

    public func flattened() -> [PlaylistItem] {
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
    
    mutating public func addItem(_ item: PlaylistItem) {
        if var items = items {
            items.append(item)
            self.items = items
        } else {
            self.items = [item]
        }
    }

    public mutating func removeAllItems() {
        items?.removeAll()
    }

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

    public mutating func swap(_ posArray: [Int], _ direction: PlaylistItemSwapDirection) -> Bool {
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
                    if items[pos].swap(posArray, direction) {
                        self.items = items
                        return true
                    }
                }
            }
        }
        return false
    }

}
