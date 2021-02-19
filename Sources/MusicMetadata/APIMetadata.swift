//
//  ListMetadata.swift
//  
//
//  Created by Robert Cheal on 2/13/21.
//

import Foundation

public struct APIMetadata: Codable {
    public var totalCount: Int
    public var limit: Int
    public var offset: Int

    public init(totalCount: Int, limit: Int, offset: Int) {
        self.totalCount = totalCount
        self.limit = limit
        self.offset = offset
    }
}

