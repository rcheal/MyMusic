//
//  Single+jsonFile..swift
//  
//
//  Created by Robert Cheal on 1/3/21.
//

import Foundation

extension Single {
    // Returns JSON encoding of Single
    public var json: Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }

    /// Returns 'prettyPrinted JSON encoding of Single
    ///
    /// Same as .json, except formats JSON for human readability
    public var jsonp: Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try? encoder.encode(self)
    }

    /// Creates Single from JSON encoding
    public static func decodeFrom(json: Data) -> Single? {
        let decoder = JSONDecoder()
        if let jsonSingle = try? decoder.decode(Single.self, from: json) {
            return jsonSingle
        }
        return nil
    }
}
