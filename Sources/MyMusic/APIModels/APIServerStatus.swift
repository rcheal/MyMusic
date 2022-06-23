//
//  APIServerStatus.swift
//  
//
//  Created by Robert Cheal on 2/11/21.
//

import Foundation

/// Struct containing MyMusicServer status information
public struct APIServerStatus: Codable {
    /// Server version
    public var version: String?
    /// API versions supported, comma seperaed list - currently 'v1'
    public var apiVersions: String?
    /// Name of server
    public var name: String?
    /// IP Address and port of server
    public var address: String?
    /// Number of albums present on server
    public var albumCount: Int?
    /// Number of stand-alone singles present on server
    public var singleCount: Int?
    /// Number of playlists present on server
    public var playlistCount: Int?
    /// Number of seconds that the server has been running
    public var upTime: Int?
    /// Time of last update to server - ISO 8601 (yyyy-MM-dd'T'HH:mm:ss.SSS'Z')
    public var lastTransactionTime: String?
    
    public init() { }
}
