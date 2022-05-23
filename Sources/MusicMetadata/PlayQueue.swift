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

    public var content: PlaylistItem

    public init() {
        content = PlaylistItem()
    }
}

extension PlayQueue: Codable {

    public enum CodingKeys: String, CodingKey {
        case autoRepeat
        case shuffle
        case content

    }

}
