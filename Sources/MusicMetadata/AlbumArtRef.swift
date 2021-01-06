//
//  AlbumArtRef.swift
//  
//
//  Created by Robert Cheal on 12/6/20.
//

import Foundation

public enum AlbumArtType: Int, Codable {
    case front
    case back
    case page
}

public enum AlbumArtFormat: Int, Codable {
    case jpg
    case png
}

public struct AlbumArtRef: Hashable, Codable {
    public var type: AlbumArtType
    public var format: AlbumArtFormat
    public var seq: Int?
    
    public init(type: AlbumArtType, format: AlbumArtFormat) {
        self.type = type
        self.format = format
    }
    
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
