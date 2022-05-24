//
//  PlayQueue.swift
//  
//
//  Created by Robert Cheal on 5/23/22.
//

import Foundation

public struct PlayQueue {

    public var autoRepeat: Bool = false
    public var shuffle: Bool = false

    public var content: [PlaylistItem] = []

}

extension PlayQueue: Codable {

    public enum CodingKeys: String, CodingKey {
        case autoRepeat
        case shuffle
        case content

    }

}

extension PlayQueue {
    public var count: Int { content.count }

    public var trackCount: Int {
        get {
            var count = 0
            for item in content {
                count += item.trackCount
            }
            return count
        }
    }

    mutating public func append(_ item: PlaylistItem) {
            content.append(item)
    }

}
