//
//  MetaDatum.swift
//  
//
//  Created by Robert Cheal on 9/7/20.
//

import Foundation

enum MetadataType: Hashable {
    case album, title, composition, subtitle, artist, supportingArtists, composer, conductor, lyricist,
         genre, publisher, copyright, encodedBy, encoderSettings, recordingYear, duration, disk, track,
         coverArtRef, audiofileRef
}

extension MetadataType: CaseIterable {
    public static var allCases: [MetadataType] {
        [   .album,
            .title,
            .composition,
            .subtitle,
            .artist,
            .supportingArtists,
            .composer,
            .conductor,
            .lyricist,
            .genre,
            .publisher,
            .copyright,
            .encodedBy,
            .encoderSettings,
            .recordingYear,
            .duration,
            .disk,
            .track,
            .coverArtRef,
            .audiofileRef
        ]
    }
    
    public static var allSharedCases: [MetadataType] {
        [   .album,
            .composition,
            .artist,
            .supportingArtists,
            .composer,
            .conductor,
            .lyricist,
            .genre,
            .publisher,
            .copyright,
            .encodedBy,
            .encoderSettings,
            .recordingYear,
            .disk,
            .coverArtRef,
        ]
    }

}

enum MetadataContentsType {
    case string
    case int
    case image
    case empty
}

public enum MetadataImageType {
    case frontCover
    case backCover
}

struct MetadataItem: Equatable {
    
    var type: MetadataType
    
    var contentsType: MetadataContentsType {
        if contentsInt != nil {
            return .int
        } else if contentsString != nil {
            return .string
        } else if contentsImage != nil {
            return .image
        } else {
            return .empty
        }
    }
    var contentsString: String?
    var contentsInt: Int?
    var imageType: MetadataImageType?
    var contentsImage: Data?
    
}

