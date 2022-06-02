//
//  Playlist+fields.swift
//  
//
//  Created by Robert Cheal on 6/2/22.
//

import Foundation

extension Playlist {

    public mutating func addFields(_ fields: String, from playlist: Playlist) {

        let components = fields.lowercased().components(separatedBy: ",")

        for component in components {
            switch component {
            case "user":
                user = playlist.user
            case "shared":
                shared = playlist.shared
            case "playlisttype":
                playlistType = playlist.playlistType
            case "autorepeat":
                autoRepeat = playlist.autoRepeat
            case "shuffle":
                shuffle = playlist.shuffle
            case "artist":
                artist = playlist.artist
            case "composer":
                composer = playlist.composer
            case "genre":
                genre = playlist.genre
            case "years":
                years = playlist.years
            case "ratings":
                ratings = playlist.ratings
            case "items":
                items = playlist.items
            default:
                break
            }
        }
    }
}
