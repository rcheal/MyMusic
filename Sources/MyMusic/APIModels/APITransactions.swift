//
//  APITransactions.swift
//  
//
//  Created by Robert Cheal on 1/15/21.
//

import Foundation

/// Struct containing list of transactions
public struct APITransactions {
    /// List of transactions requested by client
    public var transactions: [Transaction]
    private var _metadata: APIMetadata
    
    public init(transactions: [Transaction], _metadata: APIMetadata) {
        self.transactions = transactions
        self._metadata = _metadata
    }

    /// Request metadata related to transaction list
    /// - Returns: ``APIMetadata``
    public func getMetadata() -> APIMetadata { _metadata }
}

extension APITransactions: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case transactions
        case _metadata
    }
}
