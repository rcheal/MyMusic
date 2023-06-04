//
//  APIFileHashes.swift
//  
//
//  Created by Robert Cheal on 6/4/23.
//

import Foundation

public struct APIFileHashes {
    public var hashes: [FileHash]
}

public struct FileHash {
    public var filename: String
    public var hash: String?
    public var hashtype: String?
}
