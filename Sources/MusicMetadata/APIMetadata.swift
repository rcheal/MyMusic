//
//  ListMetadata.swift
//  
//
//  Created by Robert Cheal on 2/13/21.
//

import Foundation

public struct APIMetadata: Codable {
    var totalCount: Int
    var limit: Int
    var offset: Int
    
    public init(totalCount: Int, limit: Int, offset: Int) {
        self.totalCount = totalCount
        self.limit = limit
        self.offset = offset
    }
}

