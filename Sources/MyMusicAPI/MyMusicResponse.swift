//
//  MyMusicResponse.swift
//  
//
//  Created by Robert Cheal on 2/11/21.
//

import Foundation
import MusicMetadata

struct MyMusicResponse: Codable {
    var statusCode: String
    var transaction: Transaction
}
