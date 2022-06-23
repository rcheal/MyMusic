//
//  ListMetadata.swift
//  
//
//  Created by Robert Cheal on 2/13/21.
//

import Foundation

/// Struct containing information related to a returned list
public struct APIMetadata: Codable {
    /// Actual count of items in returned list
    public var totalCount: Int
    /// Request limit of items to return
    public var limit: Int
    /// Request offset of items to return
    public var offset: Int

    public init(totalCount: Int, limit: Int, offset: Int) {
        self.totalCount = totalCount
        self.limit = limit
        self.offset = offset
    }
}

