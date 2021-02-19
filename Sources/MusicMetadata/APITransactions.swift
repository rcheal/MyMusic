//
//  APITransactions.swift
//  
//
//  Created by Robert Cheal on 1/15/21.
//

import Foundation

public struct APITransactions {
    public var transactions: [Transaction]
    public var _metadata: APIMetadata
}

extension APITransactions: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case transactions
        case _metadata
    }
}
