//
//  APISingles.swift
//  
//
//  Created by Robert Cheal on 1/15/21.
//

import Foundation

public struct APISingles {
    public var singles: [Single]
    public var _metadata: APIMetadata
}

extension APISingles: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case singles
        case _metadata
    }
}
