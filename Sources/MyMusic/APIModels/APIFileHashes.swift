//
//  APIFileHashes.swift
//  
//
//  Created by Robert Cheal on 6/4/23.
//

import Foundation

public enum FileHashType: String, Codable {
    case MD5
    case SHA1
    case SHA256
    case SHA384
    case SHA512
}

public struct FileHash: Codable {
    public var filename: String
    public var hash: String?
    public var hashtype: FileHashType?

    public init(filename: String, hash: String? = nil, hashtype: FileHashType? = nil) {
        self.filename = filename
        self.hash = hash
        self.hashtype = hashtype
    }

    public enum CodingKeys: String, CodingKey {
        case filename
        case hash
        case hashtype
    }
}

public struct APIFileHashes {
    public var hashes: [FileHash]

    public init(filename: String, hash: String? = nil, hashtype: FileHashType? = nil) {
        hashes  = [FileHash(filename: filename, hash: hash, hashtype: hashtype)]
    }

    public init(_ hash: FileHash) {
        hashes = [hash]
    }

    public init(hashes: [FileHash]) {
        self.hashes = hashes
    }
}

extension APIFileHashes: Codable {
    public enum CodingKeys: String, CodingKey {
        case hashes
    }
}
