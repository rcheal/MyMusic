//
//  Album.swift
//  
//
//  Created by Robert Cheal on 9/6/20.
//

import Foundation

public struct Album: Codable {
    public var album: String
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

    public var coverArtRefs: [String]?
    
    public var audioFiles: [AudioFile] = []
    public var compositions: [Composition] = []
    
    func load(fromFrames: [ID3FrameEx]) {
        
    }

    var json: Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
    
    public static func decodeFrom(json: Data) -> Album? {
        let decoder = JSONDecoder()
        if let jsonAlbum = try? decoder.decode(Album.self, from: json) {
            return jsonAlbum
        }
        return nil
    }
    
}
