//
//  File.swift
//  
//
//  Created by Robert Cheal on 9/6/20.
//

import Foundation

public struct Single: Codable {
    public var id: String?
    public var disk: Int?
    public var track: Int
    
    public var title: String
    public var subtitle: String?
    public var artist: String?
    public var supportingArtists: [String]?
    public var composer: String?
    public var conductor: String?
    public var orchestra: String?
    public var lyricist: String?
    public var genre: String?
    public var publisher: String?
    public var copyright: String?
    public var encodedBy: String?
    public var encoderSettings: String?
    public var recordingYear: Int?
    public var duration: Int?       /// duration in seconds

    public var audiofileRef: String?

    
    init(track: Int, title: String, filename: String) {
        self.track = track
        self.title = title
        self.audiofileRef = filename
    }
}