//
//  Single+fields.swift
//  
//
//  Created by Robert Cheal on 2/1/21.
//

import Foundation

extension Single {

    /// Populate specified fields from another ``Single`` struct
    ///
    /// Used to return a slimmed down single definition for API transfer.
    /// - Parameters:
    ///   - fields: Comma separated list of field names
    ///   - single: Full ``Single`` to pull values from
    public mutating func addFields(_ fields: String, from single: Single) {

        let components = fields.lowercased().components(separatedBy: ",")
        
        for component in components {
            switch component {
            case "subtitle":
                subtitle = single.subtitle
            case "artist":
                artist = single.artist
            case "supportingartists":
                supportingArtists = single.supportingArtists
            case "composer":
                composer = single.composer
            case "conductor":
                conductor = single.conductor
            case "orchestra":
                orchestra = single.orchestra
            case "lyricist":
                lyricist = single.lyricist
            case "genre":
                genre = single.genre
            case "publisher":
                publisher = single.publisher
            case "copyright":
                copyright = single.copyright
            case "encodedby":
                encodedBy = single.encodedBy
            case "encodersettings":
                encoderSettings = single.encoderSettings
            case "recordingyear":
                recordingYear = single.recordingYear
            case "duration":
                duration = single.duration
            case "directory":
                directory = single.directory
            case "sorttitle":
                sortTitle = single.sortTitle
            case "sortartist":
                sortArtist = single.sortArtist
            case "sortcomposer":
                sortComposer = single.sortComposer
            default:
                break
            }
        }

    }
}

