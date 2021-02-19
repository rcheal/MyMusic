//
//  APIServerStatus.swift
//  
//
//  Created by Robert Cheal on 2/11/21.
//

import Foundation

public struct APIServerStatus: Codable {
    public struct Address: Codable {
        var host: String
        var port: Int
    }
    
    public var version: String
    public var apiVersions: String
    public var name: String
    public var url: Address
    public var albumCount: Int
    public var singleCount: Int
    public var playlistCount: Int
    public var upTime: Int
    public var lastTransactionTime: String
}
