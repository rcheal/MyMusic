//
//  Playlist+fields.swift
//  
//
//  Created by Robert Cheal on 2/20/21.
//

import Foundation

extension Playlist {
    
    public mutating func addFields(_ fields: String, from playlist: Playlist) {

        let components = fields.lowercased().components(separatedBy: ",")
        
        id = playlist.id
        
        for component in components {
            switch component {
            case "nextItemIndex":
                nextItemIndex = playlist.nextItemIndex
            case "items":
                items = playlist.items
            case "orderedItems":
                orderedItems = playlist.orderedItems
            default:
                break
            }
        }
    }
}

