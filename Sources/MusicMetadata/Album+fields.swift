//
//  Album+fields.swift
//  
//
//  Created by Robert Cheal on 2/1/21.
//

import Foundation

extension Album {
    
    public mutating func addFields(_ fields: String, from album: Album) {

        let components = fields.lowercased().components(separatedBy: ",")
        
        for component in components {
            switch component {
            case "subtitle":
                subtitle = album.subtitle
            case "artist":
                artist = album.artist
            case "supportingartists":
                supportingArtists = album.supportingArtists
            case "composer":
                composer = album.composer
            case "conductor":
                conductor = album.conductor
            case "orchestra":
                orchestra = album.orchestra
            case "lyricist":
                lyricist = album.lyricist
            case "genre":
                genre = album.genre
            case "publisher":
                publisher = album.publisher
            case "copyright":
                copyright = album.copyright
            case "encodedby":
                encodedBy = album.encodedBy
            case "encodersettings":
                encoderSettings = album.encoderSettings
            case "recordingyear":
                recordingYear = album.recordingYear
            case "duration":
                duration = album.duration
            case "directory":
                directory = album.directory
            case "sorttitle":
                sortTitle = album.sortTitle
            case "sortartist":
                sortArtist = album.sortArtist
            case "sortcomposer":
                sortComposer = album.sortComposer
            case "frontart":
                if let frontArt = album.frontArtRef() {
                    albumArt.addArt(frontArt)
                }
            case "backart":
                if let backArt = album.backArtRef() {
                    albumArt.addArt(backArt)
                }
            case "albumart":
                albumArt = album.albumArt
            case "contents":
                contents = album.contents
            default:
                break
            }
        }

    }
}
