//
//  AlbumArtRef.swift
//  
//
//  Created by Robert Cheal on 12/6/20.
//

import Foundation

/// Type of artwork.
public enum AlbumArtType: Int, Codable {
    /// Front cover art
    case front
    /// Back cover art
    case back
    /// Additional pages of artwork
    case page
}

/// Format of artwork file
public enum AlbumArtFormat: Int, Codable {
    /// JPEG file
    case jpg
    /// PNG file
    case png
}

/// Description of artwork file
///
/// The description consists of:
/// - type - .front, .back. or .page,
/// - format - .jpg or .png
/// - seq - page sequence when type is .page
///
/// The filename (name) of the artwork is derived from these values.
///
/// An album may have only one .front and one .back artwork.
public struct AlbumArtRef: Hashable, Codable {

    /// Artwork type
    public var type: AlbumArtType
    /// Artwork file format
    public var format: AlbumArtFormat
    /// Page sequence for `.page` types
    public var seq: Int?

    public init(type: AlbumArtType, format: AlbumArtFormat) {
        self.type = type
        self.format = format
    }

    /// Name (without extention) of artwork.
    public var name: String {
        get {
            var name: String
            switch type {
            case .front:
                name = "front"
            case .back:
                name = "back"
            case .page:
                name = "page\(seq ?? 0)"
            }
            return name.capitalized
        }

    }

    /// Filename of artwork
    public var filename: String {
        get {
            var name: String
            switch type {
            case .front:
                name = "front"
            case .back:
                name = "back"
            case .page:
                name = "page\(seq ?? 0)"
            }
            switch format {
            case .jpg:
                name += ".jpg"
            case .png:
                name += ".png"
            }
            return name
        }
    }
    
}
