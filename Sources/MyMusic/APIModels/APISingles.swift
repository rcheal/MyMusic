//
//  APISingles.swift
//  
//
//  Created by Robert Cheal on 1/15/21.
//

import Foundation

/// Struct containing list of singles
public struct APISingles {
    /// List of singles requested by client
    public var singles: [Single]
    private var _metadata: APIMetadata
    
    public init(singles: [Single], _metadata: APIMetadata) {
        self.singles = singles
        self._metadata = _metadata
    }

    /// Request metadata related to single list
    /// - Returns: ``APIMetadata``
    public func getMetadata() -> APIMetadata { _metadata }
}

extension APISingles: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case singles
        case _metadata
    }
}
