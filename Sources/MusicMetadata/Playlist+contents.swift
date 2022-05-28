//
//  Playlist+contents.swift
//  
//
//  Created by Robert Cheal on 5/28/22.
//

import Foundation

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
}
