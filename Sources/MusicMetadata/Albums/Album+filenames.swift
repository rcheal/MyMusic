//
//  File.swift
//  
//
//  Created by Robert Cheal on 2/23/21.
//

import Foundation

extension Album {
    /// Get Audio and Artwork filenames
    ///
    /// - Returns: Array of all audio and artwork filenames in Album
    public func getFilenames() -> [String] {
        var filenames = [String]()
        // Add artwork filenames
        filenames = getArtworkFilenames()
        // Add audio track filenames
        filenames.append(contentsOf: getAudioFilenames())
        return filenames
    }

    /// Get Artwork filenames
    ///
    /// - Returns: Array of all artwork filenames in Album
    public func getArtworkFilenames() -> [String] {
        var filenames = [String]()
        let count = artworkCount()
        if count > 0 {
            for index in 0..<count {
                if let filename = artRef(index)?.filename {
                    filenames.append(filename)
                }
            }
        }
        return filenames
    }

    /// Get Audio filenames
    ///
    /// - Returns: Array of all audio filenames in Album
    public func getAudioFilenames() -> [String] {
        var filenames: [String] = []
        for content in contents {
            if let single = content.single {
                filenames.append(single.filename)
            } else if let composition = content.composition {
                for movement in composition.movements {
                    filenames.append(movement.filename)
                }
            }
        }
        return filenames
    }

}
