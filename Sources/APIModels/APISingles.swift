//
//  APISingles.swift
//  
//
//  Created by Robert Cheal on 1/15/21.
//

import Foundation

public struct APISingles {
    public var singles: [Single]
    private var _metadata: APIMetadata
    
    public init(singles: [Single], _metadata: APIMetadata) {
        self.singles = singles
        self._metadata = _metadata
    }

    public func getMetadata() -> APIMetadata { _metadata }
}

extension APISingles: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case singles
        case _metadata
    }
}
