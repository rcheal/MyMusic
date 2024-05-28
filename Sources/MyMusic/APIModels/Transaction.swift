//
//  Transaction.swift
//  
//
//  Created by Robert Cheal on 2/11/21.
//

import Foundation

var iso8601Formatter: DateFormatter?

public let postMethod = "POST"
public let putMethod = "PUT"
public let deleteMethod = "DELETE"

public let albumEntity = "album"
public let singleEntity = "single"
public let playlistEntity = "playlist"

/// A struct that stores attributes of a single transaction against the MyMusicServer
public struct Transaction: Identifiable, Hashable {
    /// id of entity added, modified or deleted
    public var id: String
    /// title of entity added, modified or deleted
    public var title: String
    /// time of transaction - ISO 8601 (yyyy-MM-dd'T'HH:mm:ss.SSS'Z')
    public var time: String
    /// HTTP method - postMethod, putMethod or deleteMethod
    public var method: String
    /// MyMusic entity involved - albumEntity, singleEntity, or playlistEntity
    public var entity: String
    
    public init(method: String, entity: String, id: String, title: String) {
        self.method = method
        self.entity = entity
        self.id = id
        self.title = title

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

extension Transaction: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case id
        case title
        case time
        case method
        case entity
    }
}

