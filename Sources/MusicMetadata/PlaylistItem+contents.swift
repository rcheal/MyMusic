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
}
