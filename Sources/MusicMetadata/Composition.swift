//
//  Composition.swift
//  
//
//  Created by Robert Cheal on 9/6/20.
//

import Foundation

public struct Composition: Codable, Identifiable, Hashable {
    public var id: String
    public var albumId: String?
    public var startDisk: Int?
    public var startTrack: Int
    
    public var title: String
    public var sortTitle: String?
    public var subtitle: String?
    public var artist: String?
    public var sortArtist: String?
    public var supportingArtists: String?
    public var composer: String?
    public var sortComposer: String?
    public var conductor: String?
    public var orchestra: String?
    public var lyricist: String?
    public var genre: String?
    public var publisher: String?
    public var copyright: String?
    public var encodedBy: String?
    public var encoderSettings: String?
    public var recordingYear: Int?
    public var duration: Int       /// duration in seconds

    public internal(set) var contents: [Single] = []
    
    public init(track: Int, title: String, disk: Int? = nil) {
        id = UUID().uuidString
        duration = 0
        self.startTrack = track
        self.title = title
        self.startDisk = disk
    }
    
}