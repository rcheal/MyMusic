//
//  APIServerStatus.swift
//  
//
//  Created by Robert Cheal on 2/11/21.
//

import Foundation

public struct APIServerStatus: Codable {
    public var version: String?
    public var apiVersions: String?
    public var name: String?
    public var address: String?
    public var albumCount: Int?
    public var singleCount: Int?
    public var playlistCount: Int?
    public var upTime: Int?
    public var lastTransactionTime: String?
    
    public init() { }
}
