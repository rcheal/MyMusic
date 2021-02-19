//
//  APITransactions.swift
//  
//
//  Created by Robert Cheal on 1/15/21.
//

import Foundation

public struct APITransactions {
    var transactions: [APITransaction]
}

extension APITransactions: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case transactions
    }
}
