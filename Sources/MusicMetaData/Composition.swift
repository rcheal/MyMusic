//
//  Composition.swift
//  
//
//  Created by Robert Cheal on 9/6/20.
//

import Foundation

public struct Composition: Codable {
    public var startDisk: Int?
    public var startTrack: Int
    
    public var title: String
    public var subtitle: String?
    public var artist: String?
    public var supportingArtists: [String]?
    public var composer: String?
    public var conductor: String?
    public var lyricist: String?
    public var genre: String?
    public var publisher: String?
    public var copyright: String?
    public var encodedBy: String?
    public var encoderSettings: String?
    public var recordingYear: Int?
    public var duration: Int?       /// duration in seconds

    public var audioFiles: [AudioFile] = []
}
