//
//  AlbumContent.swift
//  
//
//  Created by Robert Cheal on 10/31/20.
//

import Foundation

/// Struct containing single or composition content
///
/// Only one of composition or single should be provided.  disk and track are convience duplicates of the child content.
public struct AlbumContent: Identifiable, Hashable {
    public var id: String  // Copy of composition.id or single.id
    public var disk: Int?
    public var track: Int
    public var composition: Composition?
    public var single: Single?
    
    public init(composition: Composition) {
        id = composition.id
        self.track = composition.startTrack
        self.disk = composition.startDisk
        self.composition = composition
    }
    
    public init(single: Single) {
        id = single.id
        self.track = single.track
        self.disk = single.disk
        self.single = single
    }
}

extension AlbumContent: Codable {
    
}

