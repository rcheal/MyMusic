//
//  Transaction+json.swift
//  
//
//  Created by Robert Cheal on 1/16/21.
//

import Foundation

extension APITransaction {
    public var json: Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
    
    public var jsonp: Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try? encoder.encode(self)
    }
    
    public static func decodeFrom(json: Data) -> APITransaction? {
        let decoder = JSONDecoder()
        if let jsonTransaction = try? decoder.decode(APITransaction.self, from: json) {
            return jsonTransaction
        }
        return nil
    }
}
