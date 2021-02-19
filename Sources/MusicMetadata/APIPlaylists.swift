//
//  APIPlaylists.swift
//  
//
//  Created by Robert Cheal on 1/16/21.
//

import Foundation

public struct APIPlaylists {
    var playlists: [PlaylistSummary]
}

extension APIPlaylists: Codable {
    
    public enum CodingKeys: String, CodingKey {
        case playlists
    }
}
