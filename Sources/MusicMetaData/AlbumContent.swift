//
//  AlbumContent.swift
//  
//
//  Created by Robert Cheal on 10/31/20.
//

import Foundation

public struct AlbumContent: Codable, Identifiable, Hashable {
    public var id: String  // Copy of composition.id or single.id
    public var disk: Int?
    public var track: Int
    public var composition: Composition?
    public var single: Single?
    
    public init(track: Int, composition: Composition, disk: Int? = nil) {
        id = composition.id
        self.track = track
        self.composition = composition
        self.disk = disk
    }
    
    public init(track: Int, single: Single, disk: Int? = nil) {
        id = single.id
        self.track = track
        self.single = single
        self.disk = disk
    }
}

