//
//  File.swift
//  
//
//  Created by Robert Cheal on 12/20/20.
//

import Foundation

public struct Movement: Identifiable, Hashable {
    public var id: String
    public var compositionId: String?
    public var albumId: String?
    public var disk: Int?
    public var track: Int
    
    public var title: String
    public var subtitle: String?
    public var duration: Int       /// duration in seconds

    public var audiofileRef: String?

    public init(track: Int, title: String, filename: String, disk: Int? = nil) {
        id = UUID().uuidString
        duration = 0
        self.disk = disk
        self.track = track
        self.title = title
        self.audiofileRef = filename
    }
}

extension Movement: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case compositionId
        case albumId
        case disk
        case track
        case title
        case subtitle
        case duration
        case audiofileRef
    }
}

