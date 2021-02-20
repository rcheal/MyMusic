//
//  APITransactions.swift
//  
//
//  Created by Robert Cheal on 1/15/21.
//

import Foundation

public struct APITransactions {
    public var transactions: [Transaction]
    public var _metadata: APIMetadata?
    
    public init(transactions: [Transaction], _metadata: APIMetadata? = nil) {
        self.transactions = transactions
        self._metadata = _metadata
    }
}

extension APITransactions: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case transactions
        case _metadata
    }
}
