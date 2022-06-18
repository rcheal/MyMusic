//
//  Movement.swift
//  
//
//  Created by Robert Cheal on 12/20/20.
//

import Foundation

/// A struct that stores metadata for a movement.
///
/// Movements - used primarily in classical music are parts of a composition (``Composition``).  Each
/// movement references an audio file (`filename`).
public struct Movement: Identifiable, Hashable {
    public var id: String
    public var compositionId: String?
    public var albumId: String?
    public var disk: Int?
    public var track: Int
    
    public var title: String
    public var subtitle: String?
    public var duration: Int       /// duration in seconds

    public var filename: String

    public init(title: String, filename: String, track: Int, disk: Int? = nil) {
        id = UUID().uuidString
        duration = 0
        self.disk = disk
        self.track = track
        self.title = title
        self.filename = filename
    }
}

extension Movement: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case compositionId
        case albumId
        case disk
        case track
        case title
        case subtitle
        case duration
        case filename
    }
}

