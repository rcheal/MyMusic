//
//  APIServerStatus.swift
//  
//
//  Created by Robert Cheal on 2/11/21.
//

import Foundation

public struct APIServerStatus: Codable {
    struct Address: Codable {
        var host: String
        var port: Int
    }
    
    var version: String
    var apiVersions: String
    var name: String
    var url: Address
    var albumCount: Int
    var singleCount: Int
    var playlistCount: Int
    var upTime: Int
    var lastTransactionTime: String
}
