//
//  APITransaction.swift
//  
//
//  Created by Robert Cheal on 2/11/21.
//

import Foundation

var iso8601Formatter: DateFormatter?

public struct APITransaction: Identifiable, Hashable {
    public var id: String
    public var time: String
    public var method: String
    public var entity: String
    
    public init(method: String, entity: String, id: String) {
        self.method = method
        self.entity = entity
        self.id = id

        if iso8601Formatter == nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            iso8601Formatter = formatter
        }

        let timestamp = iso8601Formatter!.string(from: Date())
        self.time = timestamp
    }
}

extension APITransaction: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case id
        case time
        case method
        case entity
    }
}

